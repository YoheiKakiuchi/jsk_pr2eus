(require :hrp2jsknt "package://hrpsys_ros_bridge_tutorials/models/hrp2jsknt.l")
(require :hrp2jsknt-utils "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsknt-utils.l")
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
         #|
         (list :whole-body
               (cons :group-name "whole_body")
               (cons :target-link
                     (list (send self :search-link-from-name "LARM_LINK6")
                           (send self :search-link-from-name "RARM_LINK6")))
               (cons :joint-list (append (send robot :torso :joint-list)
                                         (remove (send robot :larm_joint7)
                                             (send robot :larm :joint-list)))))|#
         )
   )
  )

#|
(setq me (instance hrp2jsknt-moveit-environment :init))
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

(setq jc (make-joint-constraints wb-joint-list))
(setq vjc (make-virtual-joint-constraints (make-coords)))
(merge-goal-constraints (list jc vjc))
|#
