extends Resource
class_name WormSettings

enum PHYS_MODE {Velocity, Force}

export(Curve) var curve_velocity = null
export(float) var normalize_dist = 50
export(float) var speed = 300
export(float) var max_velocity = 100
export(float) var seg_distance = 10
export(float) var max_distance = 20
export(float) var drag_min_dist = 10
export(float) var f_spring = 10
export(float) var f_drag = 20
export(float) var damping = 1
export(float) var damping_drag = 10
export(float) var grab_radius = 20
export(PHYS_MODE) var physics_mode = PHYS_MODE.Velocity
export(float) var squash = 0.1
export(float) var stretch = 0.1
