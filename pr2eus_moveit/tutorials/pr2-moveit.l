(ros::load-ros-manifest "pr2eus_moveit")

(load "package://pr2eus/pr2-interface.l");;
(load "package://pr2eus_moveit/euslisp/pr2eus-moveit.l");;

(unless (boundp '*pr2*) (pr2))
;; for demo.launch
(unless (boundp '*ri*) (setq *ri* (instance pr2-interface :init :joint-state-topic
                                            "/move_group/fake_controller_joint_states")))
(send *ri* :set-moveit-environment (instance moveit-environment :init))

(ros::spin-once)

(setq pose-1 #f(168.25 0.0 0.0 0.0 -65.068 0.0 -60.1606 0.0 0.0 0.0 0.0 -65.068 0.0 -60.1606 0.0 0.0 0.0))
(send *pr2* :angle-vector pose-1)
(send *ri* :angle-vector pose-1)

;; simple test
(send me :motion-plan :rarm)

(setq pose-constraint-1
      (make-pose-constraints "r_wrist_roll_link"
                             (send (car (last (send *pr2* :rarm :links))) :copy-worldcoords)
                             :frame_id "base_footprint" :use-position nil
                             :tolerance_rx 0.4 :tolerance_ry 0.4 :tolerance_rz 0.4))
#|
(setq pose-constraint-2
      (make-pose-constraints "r_wrist_roll_link"
                             (send (car (last (send *pr2* :rarm :links))) :copy-worldcoords)
                             :frame_id "base_footprint" :use-position t
                             :tolerance_rx 0.4 :tolerance_ry 0.4 :tolerance_rz 0.4))

(setq pose-constraint-3
      (make-pose-constraints "r_wrist_roll_link"
                             (send (car (last (send *pr2* :rarm :links))) :copy-worldcoords)
                             :frame_id "world" :use-position t
                             :tolerance_rx 0.4 :tolerance_ry 0.4 :tolerance_rz 0.4))

(setq vj-constraint (make-virtual-joint-constraints (make-coords :pos (float-vector 400 0 0))))
|#
;; constraint test
(send me :motion-plan :rarm :path_constraints pose-constraint-1)
;;(send me :motion-plan :rarm :path_constraints pose-constraint-2)
;;(send me :motion-plan :rarm :path_constraints pose-constraint-3)

;; move base test
;;(send me :motion-plan-raw "base" :goal_constraints vj-constraint)
;;(send ms :motion-plan-raw "rarm-base"
;;      (merge-constraint pose-constraint-3 vj-constraint))

;; robot interface test
(send *ri* :angle-vector (send *pr2* :angle-vector))
(send *ri* :wait-interpolation)

(send *ri* :move-end-coords-plan cds-tgt
      :move-arm use-arm :use-torso use-torso))
(send *ri* :angle-vector-motion-plan
          #f(50.0 60.0 74.0 90.0 -120.0 20.0 -50.0 180.0 -60.0 74.0 -90.0 -120.0 -20.0 -50.0 180.0 0.0 48.0)
          :move-arm use-arm :use-torso use-torso)

;; use obstacles