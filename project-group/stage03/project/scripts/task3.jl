using Plots

m = 1.0
k = 1.0
N = 32
ω0 = sqrt(k/m)
Δt = 0.01
Tmax = 200.0
Nsteps = Int(round(Tmax/Δt))

ω_l = [2ω0 * sin(l*π/(2*(N+1))) for l in 1:N]

function dsp(x)
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

l_excite = 1
A = 0.1
y = [A * sin(π*l_excite*i/(N+1)) for i in 1:N]
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

E_history = zeros(5, Nsteps÷100)
t_history = zeros(Nsteps÷100)

let
    f = compute_forces(y)
    b_prev = dsp(y)
    step_counter = 0

    for step in 1:Nsteps
        v .+= (f ./ m) .* Δt
        y .+= v .* Δt
        f = compute_forces(y)

        if step % 100 == 0
            step_counter += 1
            t_history[step_counter] = step * Δt

            b_curr = dsp(y)

            if step_counter == 1
                b_dot = zeros(N)
            else
                b_dot = (b_curr - b_prev) / (100 * Δt)
            end

            for l in 1:5
                E_history[l, step_counter] = 0.5 * (b_dot[l]^2 + ω_l[l]^2 * b_curr[l]^2)
            end

            b_prev = b_curr
        end
    end
end

E_total_0 = sum(E_history[:, 1])
if E_total_0 > 0
    E_history ./= E_total_0
end

plot(t_history, E_history',
     title="Энергия мод (Гармонический случай)",
     xlabel="Время", ylabel="Доля энергии",
     label=["Мода 1" "Мода 2" "Мода 3" "Мода 4" "Мода 5"],
     ylims=(0, 1.1))
savefig("task3.png")
println("График сохранен как task3.png")
