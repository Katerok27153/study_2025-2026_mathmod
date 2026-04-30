m = 1.0
k = 1.0
d = 1.0
N = 32

Δt = 0.01
Tmax = 100.0
Nsteps = Int(round(Tmax/Δt))

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
        v .+= (f ./ m) * Δt
        y .+= v * Δt
        f = compute_forces(y)

        if step % 1000 == 0
            println("Шаг $step, время = $(step*Δt)")
        end
    end
end

println("Моделирование завершено")
