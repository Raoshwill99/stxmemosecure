;; Automated Memo Validation and Reversal System for STX Transfers
;; Phase 2: Enhanced validation and reversal mechanism

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_MEMO (err u101))
(define-constant ERR_TRANSFER_FAILED (err u102))
(define-constant ERR_REVERSAL_FAILED (err u103))

;; Define data variables
(define-data-var minimum-memo-length uint u1)
(define-data-var reversal-fee uint u100) ;; in microstacks

;; Define data maps
(define-map allowed-wallets principal bool)
(define-map pending-reversals 
  { tx-sender: principal, recipient: principal, amount: uint }
  { memo: (optional (string-ascii 256)), block-height: uint }
)

;; Public functions

;; Function to transfer STX with memo validation
(define-public (transfer-stx-with-memo (amount uint) (recipient principal) (memo (optional (string-ascii 256))))
  (let
    (
      (sender tx-sender)
      (memo-length (default-to u0 (len memo)))
    )
    (if (or (and (is-some memo) (>= memo-length (var-get minimum-memo-length)))
            (is-allowed-wallet sender))
      (match (stx-transfer? amount sender recipient)
        success (ok success)
        error (begin
          (map-set pending-reversals 
            { tx-sender: sender, recipient: recipient, amount: amount }
            { memo: memo, block-height: block-height }
          )
          (err error)
        )
      )
      ERR_INVALID_MEMO
    )
  )
)

;; Function to reverse a failed transfer
(define-public (reverse-transfer (original-sender principal) (original-recipient principal) (original-amount uint))
  (let
    (
      (pending-reversal (unwrap! (map-get? pending-reversals { tx-sender: original-sender, recipient: original-recipient, amount: original-amount }) ERR_TRANSFER_FAILED))
      (reversal-amount (- original-amount (var-get reversal-fee)))
    )
    (asserts! (> block-height (+ (get block-height pending-reversal) u144)) ERR_UNAUTHORIZED) ;; 24 hour waiting period
    (map-delete pending-reversals { tx-sender: original-sender, recipient: original-recipient, amount: original-amount })
    (match (stx-transfer? reversal-amount original-recipient original-sender)
      success (ok success)
      error ERR_REVERSAL_FAILED
    )
  )
)

;; Admin functions

;; Set minimum memo length
(define-public (set-minimum-memo-length (new-length uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set minimum-memo-length new-length))
  )
)

;; Set reversal fee
(define-public (set-reversal-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set reversal-fee new-fee))
  )
)

;; Add allowed wallet
(define-public (add-allowed-wallet (wallet principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-set allowed-wallets wallet true))
  )
)

;; Remove allowed wallet
(define-public (remove-allowed-wallet (wallet principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-delete allowed-wallets wallet))
  )
)

;; Read-only functions

;; Check if a wallet is allowed to transfer without memo
(define-read-only (is-allowed-wallet (wallet principal))
  (default-to false (map-get? allowed-wallets wallet))
)

;; Get the current minimum memo length
(define-read-only (get-minimum-memo-length)
  (ok (var-get minimum-memo-length))
)

;; Get the current reversal fee
(define-read-only (get-reversal-fee)
  (ok (var-get reversal-fee))
)

;; Check if a transfer is pending reversal
(define-read-only (is-pending-reversal (sender principal) (recipient principal) (amount uint))
  (is-some (map-get? pending-reversals { tx-sender: sender, recipient: recipient, amount: amount }))
)