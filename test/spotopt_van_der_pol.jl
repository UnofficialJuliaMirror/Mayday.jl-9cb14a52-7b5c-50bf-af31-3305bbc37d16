function test_spotopt_van_der_pol()
	# Replicates the test from https://github.com/spot-toolbox/spotless/blob/master/spotopt/tests/example_vanDerPol.m which maximizes the verified Region of Attraction of the van der Pol oscillator about the origin. 

	x, y = generators(:x, :y)

	# System dynamics:
	f = -[y; (1 - x^2) * y - x]

	# Construct a Lyapunov function
	J = jacobian(f, :x, :y)
	A = evaluate(J, 0.0, 0.0)
	P = lyap(A', eye(2,2))
	V = ([x; y]' * P * [x; y])[1]
	Vdot = sum(grad(V, :x, :y) .* f)

	# Solve for the maximum RoA, parameterized by rho
	model = Model()
	@defVar(model, rho)
	monos = monomials([:x, :y], 0:4)
	lambda = defPolynomial(model, [:x, :y], monos)
	d = Int(floor(deg(lambda * Vdot) / 2 - 1))
	addSoSConstraint(model, lambda * Vdot + (V - rho) * (x^2 + y^2)^d)
	@setObjective(model, :Max, rho)
	solve(model)

	result = getValue(rho)
	@show result
	@test abs(result - 2.3045) < 1e-4
end



