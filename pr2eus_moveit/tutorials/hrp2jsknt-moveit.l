;;(require :hrp2jsknt "package://hrpsys_ros_bridge_tutorials/models/hrp2jsknt.l")
(require :hrp2jsknt-interface "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsknt-interface.l")
(require :pr2eus-moveit "package://pr2eus_moveit/euslisp/pr2eus-moveit.l")

(defclass hrp2jsknt-moveit-environment
  :super moveit-environment
  :slots ())

(defmethod hrp2jsknt-moveit-environment
  (:init
   (&key ((:robot rb) (hrp2jsknt)))
   (send-super :init :robot rb
               :frame-id "BODY"
               :multi-dof-joint-name "virtual_joint"
               :multi-dof-frame-id   "/odom")
   )
  (:default-configuration ()
   (list (list :rarm
               (cons :group-name "rarm")
               (cons :target-link
                     (send self :search-link-from-name "RARM_LINK6"))
               (cons :joint-list (remove (send robot :rarm_joint7) ;; gripper
                                         (send robot :rarm :joint-list)))
               )
         (list :larm
               (cons :group-name "larm")
               (cons :target-link
                     (send self :search-link-from-name "LARM_LINK6"))
               (cons :joint-list (remove (send robot :larm_joint7) ;; gripper
                                         (send robot :larm :joint-list)))
               )
         (list :rarm-torso
               (cons :group-name "rarm_torso")
               (cons :target-link
                     (send self :search-link-from-name "RARM_LINK6"))
               (cons :joint-list (append (send robot :torso :joint-list)
                                         (remove (send robot :rarm_joint7)
                                                 (send robot :rarm :joint-list))))
               )
         (list :larm-torso
               (cons :group-name "larm_torso")
               (cons :target-link
                     (send self :search-link-from-name "LARM_LINK6"))
               (cons :joint-list (append (send robot :torso :joint-list)
                                         (remove (send robot :larm_joint7)
                                                 (send robot :larm :joint-list)))))
         (list :whole-body
               (cons :group-name "whole_body")
#|
               (cons :target-link
                     (list (send self :search-link-from-name "LARM_LINK6")
                           (send self :search-link-from-name "RARM_LINK6")))
               (cons :joint-list (append (send robot :torso :joint-list)
                                         (remove (send robot :larm_joint7)
                                             (send robot :larm :joint-list))))|#
               )
         ))
  )

#|
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
|#

#|
(setq me (instance hrp2jsknt-moveit-environment :init))

(mapcar #'(lambda (x) (let* ((nm (car x)) (ag (cadr x))
                               (jt (send me :search-joint-from-name nm)))
                          (send jt :joint-angle (rad2deg ag))))
              '(("CHEST_JOINT0" -0.0136184702039)
                ("CHEST_JOINT1" 0.0434002571776)
                ("HEAD_JOINT0" 0.0)
                ("HEAD_JOINT1" 0.0)
                ("LARM_JOINT0" -0.0469413893422)
                ("LARM_JOINT1" 0.219641878395)
                ("LARM_JOINT2" 0.0141362159615)
                ("LARM_JOINT3" -0.0595850378227)
                ("LARM_JOINT4" 0.0144541004168)
                ("LARM_JOINT5" -0.214248076786)
                ("LARM_JOINT6" 0.0286123846383)
                ("RARM_JOINT0" 0.0613177835466)
                ("RARM_JOINT1" -0.0151945310476)
                ("RARM_JOINT2" 0.00796719675125)
                ("RARM_JOINT3" -0.0639324682392)
                ("RARM_JOINT4" 0.00664385286493)
                ("RARM_JOINT5" 0.0201031284581)
                ("RARM_JOINT6" -0.0795077253369)
                ("LLEG_JOINT0" 0.0034077337842)
                ("LLEG_JOINT1" 0.0270047154945)
                ("LLEG_JOINT2" -0.00112501832703)
                ("LLEG_JOINT3" 0.0273937591854)
                ("LLEG_JOINT4" -0.0653492953566)
                ("LLEG_JOINT5" -0.0221976255602)
                ("LLEG_JOINT6" 0.0)
                ("RLEG_JOINT0" 0.00340711805844)
                ("RLEG_JOINT1" 0.0268671775202)
                ("RLEG_JOINT2" -0.00376166716616)
                ("RLEG_JOINT3" 0.0324308822176)
                ("RLEG_JOINT4" -0.0678018571428)
                ("RLEG_JOINT5" -0.022053704682)
                ("RLEG_JOINT6" 0.0)))

(mapcar #'(lambda (x) (let* ((nm (car x)) (ag (cadr x))
                               (jt (send me :search-joint-from-name nm)))
                          (send jt :joint-angle (rad2deg ag))))
        '(("CHEST_JOINT0" 0.505159638058)
          ("CHEST_JOINT1" 0.727897472176)
          ("HEAD_JOINT0" 0.0)
          ("HEAD_JOINT1" 0.0)
          ("LARM_JOINT0" -1.17147713313)
          ("LARM_JOINT1" -0.121748699627)
          ("LARM_JOINT2" -0.216221079646)
          ("LARM_JOINT3" -0.451090855796)
          ("LARM_JOINT4" -0.20577663827)
          ("LARM_JOINT5" -0.329895612643)
          ("LARM_JOINT6" 0.842325249569)
          ("RARM_JOINT0" -0.664914136503)
          ("RARM_JOINT1" -0.537146278289)
          ("RARM_JOINT2" -0.194204749939)
          ("RARM_JOINT3" -0.830017055164)
          ("RARM_JOINT4" -0.608499763448)
          ("RARM_JOINT5" -0.062301767403)
          ("RARM_JOINT6" 0.168630607372)
          ("LLEG_JOINT0" -0.115371842578)
          ("LLEG_JOINT1" -0.049688516877)
          ("LLEG_JOINT2" -0.934504217226)
          ("LLEG_JOINT3" 1.49590463247)
          ("LLEG_JOINT4" -0.610909452237)
          ("LLEG_JOINT5" -0.0273085111618)
          ("LLEG_JOINT6" 0.0)
          ("RLEG_JOINT0" -0.115712653349)
          ("RLEG_JOINT1" -0.0543586540073)
          ("RLEG_JOINT2" -0.953224122796)
          ("RLEG_JOINT3" 1.58366653333)
          ("RLEG_JOINT4" -0.679738257315)
          ("RLEG_JOINT5" -0.0225647318222)
          ("RLEG_JOINT6" 0.0)))

(setq wb-joint-list
      (mapcar #'(lambda (nm) (send me :search-joint-from-name nm))
              (list "CHEST_JOINT0"
                    "CHEST_JOINT1"
                    "HEAD_JOINT0"
                    "HEAD_JOINT1"
                    "LARM_JOINT0"
                    "LARM_JOINT1"
                    "LARM_JOINT2"
                    "LARM_JOINT3"
                    "LARM_JOINT4"
                    "LARM_JOINT5"
                    "LARM_JOINT6"
                    "RARM_JOINT0"
                    "RARM_JOINT1"
                    "RARM_JOINT2"
                    "RARM_JOINT3"
                    "RARM_JOINT4"
                    "RARM_JOINT5"
                    "RARM_JOINT6"
                    "LLEG_JOINT0"
                    "LLEG_JOINT1"
                    "LLEG_JOINT2"
                    "LLEG_JOINT3"
                    "LLEG_JOINT4"
                    "LLEG_JOINT5"
                    "LLEG_JOINT6"
                    "RLEG_JOINT0"
                    "RLEG_JOINT1"
                    "RLEG_JOINT2"
                    "RLEG_JOINT3"
                    "RLEG_JOINT4"
                    "RLEG_JOINT5"
                    "RLEG_JOINT6")))

(setq jc (make-joint-constraints wb-joint-list :tolerance-above 0.0001 :tolerance-below 0.0001))
(setq vjc (make-virtual-joint-constraints
           (make-coords
            :pos (scale 1000 #f(0.0312665253018 -0.0135930777425 -0.00144999385392))
            :rot (quaternion2matrix #f(0.999804703722 -0.00239225306186 0.0195883539075 -0.0010620417094)))
           :joint-name "virtual_joint"
           :tolerance-above-list (float-vector 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001)
           :tolerance-below-list (float-vector 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001)
           ))
(setq vjc (make-virtual-joint-constraints
           (make-coords
            :pos (scale 1000 #f(-0.0559187710158 -0.0112579076682 -0.169774982774))
            :rot (quaternion2matrix #f(0.997344585048 0.0396584779662 0.0223901325309 0.0568301483948)))
           :joint-name "virtual_joint"
           :tolerance-above-list (float-vector 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001)
           :tolerance-below-list (float-vector 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001)
           ))

(setq goal-constraints (merge-goal-constraints (list jc vjc)))

(setq nvjc (make-virtual-joint-constraints
            (make-coords)
            :joint-name "virtual_joint"
            :tolerance-above-list (float-vector 0.4 0.4 0.4 0.4 0.4 0.4 0.4)
            :tolerance-below-list (float-vector 0.4 0.4 0.4 0.4 0.4 0.4 0.4)
            ))
(setq pc
      (make-pose-constraints "BODY"
                             (make-coords)
                             :frame_id "odom" :use-position nil
                             :tolerance_rx 0.8 :tolerance_ry 0.8 :tolerance_rz 0.8))

;;(send me :motion-plan-constraints :whole-body :goal-constraints goal-constraints :planning-attempts 4 :planning-time 120.0)
;;(send me :motion-plan-constraints :whole-body :goal-constraints goal-constraints :path-constraints nvjc :planning-time 120)

"whole_body[RRTstarkConfigDefault]"
"whole_body[PRMstarkConfigDefault]"
"whole_body[TRRTkConfigDefault]"
"whole_body[RRTConnectkConfigDefault]"
"whole_body[SBLkConfigDefault]"
"whole_body[ESTkConfigDefault]"
"whole_body[LBKPIECEkConfigDefault]"



"whole_body[BKPIECEkConfigDefault]"
"whole_body[KPIECEkConfigDefault]"
"whole_body[PRMkConfigDefault]"
"whole_body[RRTkConfigDefault]"
"whole_body[RRTstarkConfigDefault]"

(setq req
(instance moveit_msgs::positionikrequest :init
          :group_name "whole_body"
          :robot_state
          (instance moveit_msgs::robotstate :init
                    :joint_state
                    (instance sensor_msgs::jointstate :init
                              :header (instance std_msgs::header :init :frame_id "odom")
                              :name (mapcar #'(lambda (x) (send x :name)) (send *hrp2jsknt* :joint-list))
                              :position (scale (deg2rad 1.0) (send *hrp2jsknt* :angle-vector))
                              )
                    :multi_dof_joint_state
                    (instance sensor_msgs::multidofjointstate :init
                              :header (instance std_msgs::header :init :frame_id "odom")
                              :joint_names (list "virtual_joint")
                              :transforms (list (ros::coords->tf-transform (send *hrp2jsknt* :body_lk :worldcoords)))
                              ))
          :avoid_collisions t
          :ik_link_names (list "LARM_LINK6" "RARM_LINK6")
          :pose_stamped_vector (list
                                (ros::coords->tf-pose-stamped
                                 (send *hrp2jsknt* :larm_link6_lk :worldcoords) "odom")
                                (ros::coords->tf-pose-stamped
                                 (send *hrp2jsknt* :rarm_link6_lk :worldcoords) "odom"))
          ))



(ros::service-call "solve_ik" (instance moveit_msgs::getpositionikrequest :init :ik_request req))


|#
