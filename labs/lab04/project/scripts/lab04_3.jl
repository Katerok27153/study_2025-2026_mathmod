# ## Колебания гармонического осциллятора с затуханием и действием внешней силы
# Вариант 67: x'' + 3.3x' + 3x = 3.3sin(3t)

using DrWatson
@quickactivate "project"
using OrdinaryDiffEq
using Plots
default(fmt = :png)

# Настройки графики для Quarto
gr()
default(fmt = :png, size = (800, 450))

# Параметры
tspan = (0, 33)
p = [3.3, 3]        # [2γ, ω₀²] где 2γ = 3.3, ω₀² = 3
du0 = [1.3]        # начальная скорость (ẋ₀ = 1.3)
u0 = [0.3]          # начальное положение (y₀ = 0.3)

# Внешняя сила
f_ext(t) = 3.3 * sin(3 * t)

# Функция правой части (с внешней силой)
function f(ddu, du, u, p, t)
    g, w = p
    ddu .= -g.*du .- w.*u .+ f_ext(t)
end

# Создание и решение задачи
prob = SecondOrderODEProblem(f, du0, u0, tspan, p)
sol = solve(prob, DPRKN6(), saveat=0.05)

# График колебаний (x(t) и y(t) от времени)
p1 = plot(sol, idxs=(0, 1), label="y(t)", xlabel="t", ylabel="x, y",
          title="Колебания c затуханием и внешней силой", linewidth=2)
plot!(p1, sol, idxs=(0, 2), label="x(t)", linewidth=2)

# Фазовый портрет (y от x)
p2 = plot(sol, idxs=(2, 1), label="y от x", xlabel="x", ylabel="y",
          title="Фазовый портрет с затуханием и внешней силой", linewidth=2)

# Сохранение
mkpath(plotsdir("lab04_3"))
savefig(p1, plotsdir("lab04_3", "case3_time_variant67.png"))
savefig(p2, plotsdir("lab04_3", "case3_phase_variant67.png"))
