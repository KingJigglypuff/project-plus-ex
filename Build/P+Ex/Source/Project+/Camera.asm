############################################
Camera Refocus Refinement [DukeItOut]
############################################
#
# Project M has doubled camera speed.
# This roughly halves the refocus rate on
# a character turning around to counteract 
# this, providing a smoother experience.
############################################
float 0.145 @ $805A1E60  # Max Shift Rate             # 0.35 -> 0.145
float 0.08  @ $805A1E64  # Shift Accel                # 0.2 -> 0.08
float 0.042 @ $805A1E68  # Zoom Accel                 # 0.1 -> 0.042
float 0.175 @ $805A1EF0  # Camera Max Zoom In Rate    # 0.2 -> 0.175