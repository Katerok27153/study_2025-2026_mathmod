using Plots

m = 1.0
k = 1.0
d = 1.0
N = 32
ω0 = sqrt(k/m)
Δt = 0.001
Tmax = 50.0
Nsteps = Int(round(Tmax/Δt))

function theoretical_freq(l)
    return 2ω0 * sin(l*π/(2*(N+1)))
end

function measure_frequency(l, A)
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

    y1_history = Float64[]
    t_history = Float64[]

    F = compute_forces(y)
    for step in 1:Nsteps
        t = step * Δt
        v .+= (F ./ m) * Δt
        y .+= v * Δt
        F = compute_forces(y)

        if step % 10 == 0
            push!(y1_history, y[1])
            push!(t_history, t)
        end
    end

    crossings = 0
    prev_sign = sign(y1_history[1])
    for i in 2:length(y1_history)
        curr_sign = sign(y1_history[i])
        if curr_sign != prev_sign && curr_sign != 0
            crossings += 1
            prev_sign = curr_sign
        end
    end

    if crossings >= 2
        T_exp = 2 * t_history[end] / crossings
        ω_exp = 2π / T_exp
        return ω_exp
    else
        return 0.0
    end
end

println("\nСравнение теоретических и экспериментальных частот:")
println("l\tТеоретическая\tЭкспериментальная\tОтклонение")
for l in 1:5
    ω_theor = theoretical_freq(l)
    ω_exp = measure_frequency(l, 0.1)
    error = abs(ω_exp - ω_theor) / ω_theor * 100
    println("$l\t$(round(ω_theor, digits=4))\t\t$(round(ω_exp, digits=4))\t\t$(round(error, digits=2))%")
end
