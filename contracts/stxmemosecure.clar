;; Automated Memo Validation and Reversal System for STX Transfers
;; Initial Commit

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_MEMO (err u101))

;; Define data variables
(define-data-var minimum-memo-length uint u1)

;; Define data maps
(define-map allowed-wallets principal bool)

;; Public functions

;; Function to transfer STX with memo validation
(define-public (transfer-stx-with-memo (amount uint) (recipient principal) (memo (optional (string-ascii 256))))
  (let
    (
      (sender tx-sender)
    )
    (if (and (is-some memo) (>= (len (unwrap-panic memo)) (var-get minimum-memo-length)))
      (stx-transfer? amount sender recipient)
      (if (is-allowed-wallet sender)
        (stx-transfer? amount sender recipient)
        ERR_INVALID_MEMO
      )
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