m_light = 1.0
m_heavy = 2.0
k = 1.0
d = 1.0
N = 32

Δt = 0.001
Tmax = 100.0
Nsteps = Int(round(Tmax/Δt))

m = Float64[]
for i in 1:N
    if i % 2 == 1
        push!(m, m_light)
    else
        push!(m, m_heavy)
    end
end

l = 1
A = 0.1
y = [A * sin(π*l*i/(N+1)) for i in 1:N]
v = zeros(N)

function compute_forces(y)
    F = zeros(N)
    for i in 1:N
        y_left = (i > 1) ? y[i-1] : 0.0
        y_right = (i < N) ? y[i+1] : 0.0
        F[i] = k * (y_right - 2*y[i] + y_left)
    end
    return F
end

let
    f = compute_forces(y)
    for step in 1:Nsteps
        t = step * Δt
        v .+= (f ./ m) * Δt
        y .+= v * Δt
        f = compute_forces(y)

        if step % 10000 == 0
            println("Шаг $step, время = $(round(t, digits=1))")
        end
    end
end

println("Моделирование цепочки с чередующимися массами завершено")
println("m_light = $m_light, m_heavy = $m_heavy")
