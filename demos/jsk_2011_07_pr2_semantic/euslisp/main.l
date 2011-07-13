#!/usr/bin/env roseus

(load "package://jsk_maps/src/eng2-scene.l")
(load "package://pr2eus/pr2-interface.l")
(load "knowrob-interface.l") ;; -> json_prolog/src
(load "actions.l")

(ros::roseus "demo_main")

(defun init ()
  ;; env
  ;;  (setq *scene* (make-eng2-scene))
  (unless (boundp '*pr2*) (pr2))
  (unless (boundp '*ri*) (setq *ri* (instance pr2-interface :init)))
  (unless (boundp '*tfl*)(setq *tfl* (instance ros::transform-listener :init)))
  (setq *knowrob* (instance json_prolog :init "json_prolog"))
  ;; callbacks
  (ros::subscribe "/query" std_msgs::string #'identity)
  )

(defun insert-robot-pose ()
  (let (pose po ret
	     (type "'http://ias.cs.tum.edu/kb/knowrob.owl#Robot'")
	     (robot "'http://jsk.t.u-tokyo.ac.jp/knowrob.owl#pr2'"))
    (ros::spin-once)
    (setq pose (send *tfl* :lookup-transform "/map" "/base_footprint" (ros::time 0)))
    (send pose :locate (scale 0.001 (send pose :worldpos)) :world)
    (setq po (coerce (array-entity (send pose :4x4)) cons))
    (setq po (mapcan #'(lambda(x)(coerce (format nil ",~a" x) cons)) po))
    (setq po (coerce (cdr po) string))
    (send *knowrob* :query
	  (list->prolog '((create_object_instance ,type ,robot)))) ;; always success
    (setq ret (send *knowrob* :query
		    (list->prolog '((update_pose ,robot ,(format nil "[~a]" po))))))
    ret ))

;; ask to knowrob
(defun ask-query-and-move (&optional (type "Cup"))
  (let* (;(type (send msg :data))
		 solutions pose)
    (setq solutions (find-similar-objects-with-info type))
    (when solutions
      (setq solution (find-if #'(lambda(x)(equal (cadr (assoc "IMAGE" x :test #'equal)) "http://jsk-ros-pkg.svn.sourceforge.net/viewvc/jsk-ros-pkg/trunk/demos/jsk_2011_07_pr2_semantic/data/cup-cotesys.jpg")) solutions)) ;; for cotesys-mug
      (setq obj (cadr (assoc "OBJ" (car solution) :test #'equal)))
	  (setq robot-pose (cadr (assoc "POSE_SPOT" (car solution) :test #'equal)))
	  (ros::spin-once)
      (setq robot-original-pose (send *tfl* :lookup-transform "/map" "/base_footprint" (ros::time 0)))
      (send *ri* :move-to robot-pose) ;; robot moves
      (ros::spin-once)
      (send *pr2* :move-to (send *tfl* :lookup-transform "/map" "/base_footprint" (ros::time 0)) :world)
	  (setq obj-pose (cadr (assoc "POSE_OBJ" solution :test #'equal)))
      (send *pr2* :head :look-at (send obj-pose :worldpos))
      (send *ri* :angle-vector (send *pr2* :angle-vector) 2000)
      (send *ri* :wait-interpolation)
      ;; grasp cup here
	  (check)
	  (pick :larm)
      ;; go to somewhere
	  (pr2-tuckarm-pose :larm)
	  (send *ri* :move-to robot-original-pose)
	  (hand-over)
	  )))

;;
(progn
  (init)  ;; for pr2 setup
  (init2) ;; for cup detection
)
;(ask-query-and-move "Cup")
;(ros::spin)
;(exit)
