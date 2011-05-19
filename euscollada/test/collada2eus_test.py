#!/usr/bin/env python
import roslib; roslib.load_manifest('test_roslaunch')

import os
import unittest

## A sample python unit test
class TestCollada2Eus(unittest.TestCase):
    def check_euscollada(self,filename,function):
        print os.system('rosrun euscollada collada2eus test/'+filename+'.zae test/'+filename+'.l')
        callstr = 'irteusgl \"(defun my-exit (&rest args) (unix::_exit -1))\" \"(lisp::install-error-handler #\'my-exit)\" \"(load \\"test/'+filename+'.l\\"\" \"(objects ('+function+'))\" \"(send *viewer* :viewsurface :write-to-image-file \\"test/'+filename+'.ppm\\")\" \"(exit 0)\"'
        self.assertEqual(os.system(callstr),0)

    def test_pa10(self):
        self.check_euscollada("mitsubishi-pa10","Mitsubishi-PA10")
    def test_puma(self):
        self.check_euscollada("unimation-pumaarm","PUMA")
    def test_cob(self):
        self.check_euscollada("care-o-bot3","cob3-2")
    def test_darpa(self):
        self.check_euscollada("darpa-arm","darpa_arm_robot")

if __name__ == '__main__':
    import rostest
    rostest.unitrun('test_collada2eus', 'test_collada2eus', TestCollada2Eus)

