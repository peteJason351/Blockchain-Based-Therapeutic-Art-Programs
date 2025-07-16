;; Trauma-Informed Care & Analytics Contract
;; Specialized contract for trauma-informed therapeutic practices and outcome analytics

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-INVALID-PARTICIPANT (err u201))
(define-constant ERR-INVALID-THERAPIST (err u202))
(define-constant ERR-CONSENT-REQUIRED (err u203))
(define-constant ERR-SAFETY-PROTOCOL-VIOLATION (err u204))
(define-constant ERR-INVALID-ASSESSMENT (err u205))
(define-constant ERR-CRISIS-INTERVENTION-NEEDED (err u206))
(define-constant ERR-INSUFFICIENT-DATA (err u207))

;; Contract references
(define-constant CONTRACT-OWNER tx-sender)

;; Authorized mentors for trauma-informed care
(define-map authorized-mentors
  principal
  bool
)

;; Trauma-informed care data structures
(define-map trauma-assessments
  {participant: principal, assessment-id: uint}
  {
    assessment-date: uint,
    assessor: principal,
    trauma-history-acknowledged: bool,
    trigger-warnings: (string-ascii 300),
    safety-plan: (string-ascii 400),
    coping-mechanisms: (string-ascii 300),
    support-network: (string-ascii 200),
    crisis-contacts: (string-ascii 200),
    therapeutic-goals: (string-ascii 300),
    consent-level: uint ;; 1-5 scale
  }
)

(define-map therapeutic-outcomes
  {participant: principal, outcome-id: uint}
  {
    measurement-date: uint,
    emotional-regulation-score: uint,
    anxiety-level: uint,
    depression-indicators: uint,
    self-efficacy-score: uint,
    social-connection-score: uint,
    creative-expression-score: uint,
    trauma-symptoms-severity: uint,
    overall-wellbeing: uint,
    sessions-since-last-measure: uint
  }
)

(define-map safety-incidents
  {participant: principal, incident-id: uint}
  {
    incident-date: uint,
    incident-type: (string-ascii 50),
    severity-level: uint,
    trigger-identified: bool,
    immediate-response: (string-ascii 400),
    follow-up-required: bool,
    reporting-mentor: principal,
    resolution-status: (string-ascii 30),
    lessons-learned: (string-ascii 300)
  }
)

(define-map crisis-interventions
  {participant: principal, intervention-id: uint}
  {
    intervention-date: uint,
    crisis-type: (string-ascii 50),
    intervention-actions: (string-ascii 500),
    emergency-contacts-notified: bool,
    professional-referral: bool,
    follow-up-scheduled: bool,
    intervening-staff: principal,
    outcome: (string-ascii 100)
  }
)

(define-map therapeutic-goals
  {participant: principal, goal-id: uint}
  {
    goal-description: (string-ascii 300),
    target-completion: uint,
    progress-percentage: uint,
    milestones-achieved: uint,
    setbacks-encountered: uint,
    support-needed: (string-ascii 200),
    last-updated: uint,
    goal-status: (string-ascii 20)
  }
)

(define-map healing-journeys
  {participant: principal, journey-id: uint}
  {
    journey-start: uint,
    current-phase: (string-ascii 30),
    breakthrough-moments: (string-ascii 500),
    artistic-evolution: (string-ascii 400),
    emotional-growth: (string-ascii 400),
    relationship-improvements: (string-ascii 300),
    coping-strategy-development: (string-ascii 400),
    future-aspirations: (string-ascii 300)
  }
)

(define-map mentor-trauma-training
  principal
  {
    certification-date: uint,
    training-provider: (string-ascii 100),
    specializations: (string-ascii 200),
    renewal-date: uint,
    crisis-intervention-certified: bool,
    supervision-hours: uint,
    continuing-education-credits: uint
  }
)

(define-map group-dynamics
  {session-id: uint, group-id: uint}
  {
    group-composition: (string-ascii 300),
    trauma-informed-structure: bool,
    peer-support-level: uint,
    collective-healing-indicators: uint,
    group-safety-score: uint,
    artistic-collaboration: bool,
    shared-experience-bonding: uint
  }
)

;; Counters
(define-data-var assessment-counter uint u0)
(define-data-var outcome-counter uint u0)
(define-data-var incident-counter uint u0)
(define-data-var intervention-counter uint u0)
(define-data-var goal-counter uint u0)
(define-data-var journey-counter uint u0)

;; Public functions

;; Authorize mentor for trauma-informed care
(define-public (authorize-mentor (mentor principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (begin
      (map-set authorized-mentors mentor true)
      (ok true)
    )
    ERR-NOT-AUTHORIZED
  )
)

;; Conduct trauma assessment
(define-public (conduct-trauma-assessment (participant principal) (trigger-warnings (string-ascii 300))
                                        (safety-plan (string-ascii 400)) (coping-mechanisms (string-ascii 300))
                                        (support-network (string-ascii 200)) (crisis-contacts (string-ascii 200))
                                        (therapy-goals (string-ascii 300)) (consent-level uint))
  (let ((assessment-id (+ (var-get assessment-counter) u1))
        (assessor tx-sender))
    (if (default-to false (map-get? authorized-mentors assessor))
      (begin
        (map-set trauma-assessments {participant: participant, assessment-id: assessment-id} {
          assessment-date: stacks-block-height,
          assessor: assessor,
          trauma-history-acknowledged: true,
          trigger-warnings: trigger-warnings,
          safety-plan: safety-plan,
          coping-mechanisms: coping-mechanisms,
          support-network: support-network,
          crisis-contacts: crisis-contacts,
          therapeutic-goals: therapy-goals,
          consent-level: consent-level
        })
        (var-set assessment-counter assessment-id)
        (ok assessment-id)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Record therapeutic outcomes
(define-public (record-therapeutic-outcomes (participant principal) (emotional-regulation uint) (anxiety-level uint)
                                          (depression-indicators uint) (self-efficacy uint) (social-connection uint)
                                          (creative-expression uint) (trauma-symptoms uint) (overall-wellbeing uint)
                                          (sessions-since-last uint))
  (let ((outcome-id (+ (var-get outcome-counter) u1)))
    (if (default-to false (map-get? authorized-mentors tx-sender))
      (begin
        (map-set therapeutic-outcomes {participant: participant, outcome-id: outcome-id} {
          measurement-date: stacks-block-height,
          emotional-regulation-score: emotional-regulation,
          anxiety-level: anxiety-level,
          depression-indicators: depression-indicators,
          self-efficacy-score: self-efficacy,
          social-connection-score: social-connection,
          creative-expression-score: creative-expression,
          trauma-symptoms-severity: trauma-symptoms,
          overall-wellbeing: overall-wellbeing,
          sessions-since-last-measure: sessions-since-last
        })
        (var-set outcome-counter outcome-id)
        (ok outcome-id)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Report safety incident
(define-public (report-safety-incident (participant principal) (incident-type (string-ascii 50)) (severity-level uint)
                                      (trigger-identified bool) (immediate-response (string-ascii 400))
                                      (follow-up-required bool))
  (let ((incident-id (+ (var-get incident-counter) u1)))
    (if (default-to false (map-get? authorized-mentors tx-sender))
      (begin
        (map-set safety-incidents {participant: participant, incident-id: incident-id} {
          incident-date: stacks-block-height,
          incident-type: incident-type,
          severity-level: severity-level,
          trigger-identified: trigger-identified,
          immediate-response: immediate-response,
          follow-up-required: follow-up-required,
          reporting-mentor: tx-sender,
          resolution-status: "reported",
          lessons-learned: ""
        })
        (var-set incident-counter incident-id)
        (ok incident-id)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Initiate crisis intervention
(define-public (initiate-crisis-intervention (participant principal) (crisis-type (string-ascii 50))
                                           (intervention-actions (string-ascii 500)) (emergency-contacts-notified bool)
                                           (professional-referral bool) (follow-up-scheduled bool))
  (let ((intervention-id (+ (var-get intervention-counter) u1)))
    (if (default-to false (map-get? authorized-mentors tx-sender))
      (begin
        (map-set crisis-interventions {participant: participant, intervention-id: intervention-id} {
          intervention-date: stacks-block-height,
          crisis-type: crisis-type,
          intervention-actions: intervention-actions,
          emergency-contacts-notified: emergency-contacts-notified,
          professional-referral: professional-referral,
          follow-up-scheduled: follow-up-scheduled,
          intervening-staff: tx-sender,
          outcome: "in-progress"
        })
        (var-set intervention-counter intervention-id)
        (ok intervention-id)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Set therapeutic goals
(define-public (set-therapeutic-goals (participant principal) (goal-description (string-ascii 300))
                                     (target-completion uint) (support-needed (string-ascii 200)))
  (let ((goal-id (+ (var-get goal-counter) u1)))
    (if (default-to false (map-get? authorized-mentors tx-sender))
      (begin
        (map-set therapeutic-goals {participant: participant, goal-id: goal-id} {
          goal-description: goal-description,
          target-completion: target-completion,
          progress-percentage: u0,
          milestones-achieved: u0,
          setbacks-encountered: u0,
          support-needed: support-needed,
          last-updated: stacks-block-height,
          goal-status: "active"
        })
        (var-set goal-counter goal-id)
        (ok goal-id)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Update goal progress
(define-public (update-goal-progress (participant principal) (goal-id uint) (progress-percentage uint)
                                    (milestones-achieved uint) (setbacks-encountered uint))
  (let ((goal-key {participant: participant, goal-id: goal-id}))
    (if (default-to false (map-get? authorized-mentors tx-sender))
      (begin
        (let ((goal-data (unwrap! (map-get? therapeutic-goals goal-key) ERR-INVALID-PARTICIPANT)))
          (map-set therapeutic-goals goal-key (merge goal-data {
            progress-percentage: progress-percentage,
            milestones-achieved: milestones-achieved,
            setbacks-encountered: setbacks-encountered,
            last-updated: stacks-block-height,
            goal-status: (if (>= progress-percentage u100) "completed" "active")
          }))
        )
        (ok true)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Create healing journey entry
(define-public (create-healing-journey (participant principal) (current-phase (string-ascii 30))
                                      (breakthrough-moments (string-ascii 500)) (artistic-evolution (string-ascii 400))
                                      (emotional-growth (string-ascii 400)) (relationship-improvements (string-ascii 300))
                                      (coping-strategy-development (string-ascii 400)) (future-aspirations (string-ascii 300)))
  (let ((journey-id (+ (var-get journey-counter) u1)))
    (if (default-to false (map-get? authorized-mentors tx-sender))
      (begin
        (map-set healing-journeys {participant: participant, journey-id: journey-id} {
          journey-start: stacks-block-height,
          current-phase: current-phase,
          breakthrough-moments: breakthrough-moments,
          artistic-evolution: artistic-evolution,
          emotional-growth: emotional-growth,
          relationship-improvements: relationship-improvements,
          coping-strategy-development: coping-strategy-development,
          future-aspirations: future-aspirations
        })
        (var-set journey-counter journey-id)
        (ok journey-id)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Register mentor trauma training
(define-public (register-trauma-training (training-provider (string-ascii 100)) (specializations (string-ascii 200))
                                        (renewal-date uint) (crisis-intervention-certified bool)
                                        (supervision-hours uint) (continuing-education-credits uint))
  (let ((mentor tx-sender))
    (if (default-to false (map-get? authorized-mentors mentor))
      (begin
        (map-set mentor-trauma-training mentor {
          certification-date: stacks-block-height,
          training-provider: training-provider,
          specializations: specializations,
          renewal-date: renewal-date,
          crisis-intervention-certified: crisis-intervention-certified,
          supervision-hours: supervision-hours,
          continuing-education-credits: continuing-education-credits
        })
        (ok true)
      )
      ERR-INVALID-THERAPIST
    )
  )
)

;; Read-only functions

;; Get trauma assessment
(define-read-only (get-trauma-assessment (participant principal) (assessment-id uint))
  (map-get? trauma-assessments {participant: participant, assessment-id: assessment-id})
)

;; Get therapeutic outcomes
(define-read-only (get-therapeutic-outcomes (participant principal) (outcome-id uint))
  (map-get? therapeutic-outcomes {participant: participant, outcome-id: outcome-id})
)

;; Get safety incident
(define-read-only (get-safety-incident (participant principal) (incident-id uint))
  (map-get? safety-incidents {participant: participant, incident-id: incident-id})
)

;; Get crisis intervention
(define-read-only (get-crisis-intervention (participant principal) (intervention-id uint))
  (map-get? crisis-interventions {participant: participant, intervention-id: intervention-id})
)

;; Get therapeutic goals
(define-read-only (get-therapeutic-goals (participant principal) (goal-id uint))
  (map-get? therapeutic-goals {participant: participant, goal-id: goal-id})
)

;; Get healing journey
(define-read-only (get-healing-journey (participant principal) (journey-id uint))
  (map-get? healing-journeys {participant: participant, journey-id: journey-id})
)

;; Get mentor trauma training
(define-read-only (get-mentor-trauma-training (mentor principal))
  (map-get? mentor-trauma-training mentor)
)

;; Check if mentor is authorized
(define-read-only (is-authorized-mentor (mentor principal))
  (default-to false (map-get? authorized-mentors mentor))
)

;; Get group dynamics
(define-read-only (get-group-dynamics (session-id uint) (group-id uint))
  (map-get? group-dynamics {session-id: session-id, group-id: group-id})
)

;; Analytics functions

;; Calculate trauma recovery progress (requires external participant data)
(define-read-only (calculate-trauma-recovery-progress (total-sessions uint) (enrolled-at uint) (trauma-consent bool))
  (some {
    total-sessions: total-sessions,
    current-level: (if (>= total-sessions u10) "advanced"
                     (if (>= total-sessions u5) "intermediate" "beginner")),
    trauma-recovery-percentage: (if (>= total-sessions u15) u80
                                  (if (>= total-sessions u10) u60
                                    (if (>= total-sessions u5) u40
                                      (* total-sessions u8)))),
    enrolled-duration: (- stacks-block-height enrolled-at),
    trauma-informed-care: trauma-consent
  })
)

;; Calculate overall program effectiveness
(define-read-only (calculate-program-effectiveness)
  (some {
    total-assessments: (var-get assessment-counter),
    total-outcomes-measured: (var-get outcome-counter),
    safety-incidents: (var-get incident-counter),
    crisis-interventions: (var-get intervention-counter),
    therapeutic-goals-set: (var-get goal-counter),
    healing-journeys-documented: (var-get journey-counter),
    program-safety-score: (if (> (var-get assessment-counter) u0)
                           (- u100 (/ (* (var-get incident-counter) u100) (var-get assessment-counter)))
                           u100),
    last-updated: stacks-block-height
  })
)

;; Get counters
(define-read-only (get-assessment-counter)
  (var-get assessment-counter)
)

(define-read-only (get-outcome-counter)
  (var-get outcome-counter)
)

(define-read-only (get-incident-counter)
  (var-get incident-counter)
)

(define-read-only (get-intervention-counter)
  (var-get intervention-counter)
)

(define-read-only (get-goal-counter)
  (var-get goal-counter)
)

(define-read-only (get-journey-counter)
  (var-get journey-counter)
)
