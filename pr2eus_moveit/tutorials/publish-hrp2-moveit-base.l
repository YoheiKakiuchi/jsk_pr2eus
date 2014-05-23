#!/usr/bin/env roseus

(require :hrp2jsknt-interface "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsknt-interface.l")
(hrp2jsknt-init)
(setq *tfb* (instance ros::transform-broadcaster :init))
(setq *default-foot* (make-coords :pos (float-vector 35.589 0 0)))
(setq *default-body* (make-coords :pos (float-vector 0 0 705)))

;; (objects (list (send *ri* :robot)))

(defun publish-base-tf ()
  (let ((robot (send *ri* :robot)))
    (send *ri* :spin-once)
    (send robot :angle-vector
          (send *ri* :state :potentio-vector)) ;; update robot posture
    (send robot :fix-leg-to-coords *default-foot*)
    (let ((req (send *default-body* :transformation
                     (send robot :body_lk :worldcoords)))
          cds)
      (setq cds (send (send *default-body* :copy-worldcoords)
                      :transform (send req :inverse-transformation)))
      (pprint cds)
      (send *tfb* :send-transform cds "odom" "moveit_base")
      )))

(ros::rate 20)
(do-until-key
 (ros::sleep)
 (publish-base-tf))