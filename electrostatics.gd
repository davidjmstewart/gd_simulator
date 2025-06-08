class_name Electrostatics
extends Object 

# e_0, epsilon nought, the absolute dieletric permittivity of a classical vacuum
const PERMITTIVITY_VACUUM = 8.8541878188e-12

static func calculate_field_at_points(point_charges: Array[Charge], simulation_points: Array) -> Array[Vector2]:
	var electric_field_vectors: Array[Vector2]
	electric_field_vectors.resize(simulation_points.size())

	for i in simulation_points.size():
		var p = simulation_points[i]
		var super_position_vector = Vector2.ZERO

		for charge in point_charges:
			# v_diff is a vector pointing from the point charge to the simulation point
			var v_diff = p - charge.position
			
			# Avoid division by zero if a point is on top of a charge
			if v_diff.is_zero_approx():
				continue

			var r_hat = v_diff.normalized()
			var distance_sq = v_diff.length_squared()
			
			# E = (1 / 4πε) * (Q / r^2) * r̂
			var field_magnitude = (1.0 / (4.0 * PI * PERMITTIVITY_VACUUM)) * charge.Q / distance_sq
			super_position_vector += field_magnitude * r_hat

		electric_field_vectors[i] = super_position_vector
		
	return electric_field_vectors
