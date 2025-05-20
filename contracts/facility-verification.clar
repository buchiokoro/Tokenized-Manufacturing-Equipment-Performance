;; facility-verification.clar
;; This contract validates production sites

(define-data-var admin principal tx-sender)

;; Map to store verified facilities
(define-map verified-facilities principal
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    verified: bool,
    verification-date: uint
  }
)

;; Function to register a new facility
(define-public (register-facility (name (string-utf8 100)) (location (string-utf8 100)))
  (let ((caller tx-sender))
    (if (map-insert verified-facilities caller
          {
            name: name,
            location: location,
            verified: false,
            verification-date: u0
          })
        (ok true)
        (err u1) ;; Facility already registered
    )
  )
)

;; Function to verify a facility (admin only)
(define-public (verify-facility (facility-owner principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (match (map-get? verified-facilities facility-owner)
        facility (begin
          (map-set verified-facilities facility-owner
            (merge facility {verified: true, verification-date: block-height}))
          (ok true)
        )
        (err u2) ;; Facility not found
      )
      (err u3) ;; Not authorized
    )
  )
)

;; Function to check if a facility is verified
(define-read-only (is-facility-verified (facility-owner principal))
  (match (map-get? verified-facilities facility-owner)
    facility (ok (get verified facility))
    (err u2) ;; Facility not found
  )
)

;; Function to get facility details
(define-read-only (get-facility-details (facility-owner principal))
  (map-get? verified-facilities facility-owner)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
      (begin
        (var-set admin new-admin)
        (ok true)
      )
      (err u3) ;; Not authorized
    )
  )
)
