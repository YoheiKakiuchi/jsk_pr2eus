(require :hrp2jsknt "package://hrpsys_ros_bridge_tutorials/models/hrp2jsknt.l")
(require :hrp2jsknt-utils "package://hrpsys_ros_bridge_tutorials/euslisp/hrp2jsknt-utils.l")
(require :pr2eus-moveit "package://pr2eus_moveit/euslisp/pr2eus-moveit.l")

(defclass hrp2jsknt-moveit-environment
  :super moveit-environment
  :slots ())

(defmethod hrp2jsknt-moveit-environment
  (:init
   (&key ((:robot rb) (hrp2jsk)))
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
