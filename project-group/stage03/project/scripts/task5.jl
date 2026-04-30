using Plots

m = 1.0
k = 1.0
α = 0.5
N = 32

Δt = 0.01
Tmax = 5000.0
Nsteps = Int(round(Tmax/Δt))

ω0 = sqrt(k/m)

ω_l = [2ω0 * sin(l*π/(2*(N+1))) for l in 1:N]

function dst(x)
    b = zeros(N)
    for l in 1:N
        s = 0.0
        for j in 1:N
            s += x[j] * sin(π*l*j/(N+1))
        end
        b[l] = s * sqrt(2/(N+1))
    end
    return b
end

function forces(y)
    F = zeros(N)
    for i in 1:N
        yL = (i > 1) ? y[i-1] : 0.0
        yR = (i < N) ? y[i+1] : 0.0

        ΔL = y[i] - yL
        ΔR = yR - y[i]

        F[i] = k*(yR - 2y[i] + yL) + α*(ΔR^2 - ΔL^2)
    end
    return F
end

A = 0.2
y = [A * sin(π*i/(N+1)) for i in 1:N]
v = zeros(N)

save_every = 50
Nt = Nsteps ÷ save_every

E_modes = zeros(N, Nt)
t_hist = zeros(Nt)

let
    f = forces(y)
    counter = 0

    for step in 1:Nsteps
        y .+= v .* Δt .+ 0.5 .* (f ./ m) .* Δt^2
        f_new = forces(y)
        v .+= 0.5 .* (f .+ f_new) ./ m .* Δt
        f = f_new

        if step % save_every == 0
            counter += 1
            t_hist[counter] = step * Δt

            b = dst(y)
            b_dot = dst(v)

            for l in 1:N
                E_modes[l, counter] = 0.5 * (b_dot[l]^2 + ω_l[l]^2 * b[l]^2)
            end

            E_total = sum(E_modes[:, counter])
            if E_total > 0
                E_modes[:, counter] ./= E_total
            end
        end
    end
end

plot(title="FPU-α: рекурренция энергии мод",
     xlabel="Время",
     ylabel="Доля энергии",
     ylims=(0, 1.05))

for l in 1:6
    plot!(t_hist, E_modes[l, :], label="мода $l")
end

savefig("task5_fpu.png")
println("Готово: task5_fpu.png")
