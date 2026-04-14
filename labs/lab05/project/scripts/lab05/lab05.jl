using DrWatson
@quickactivate "project"
using OrdinaryDiffEq
using Plots
default(fmt = :png)

u0 = [7, 29]
p = [-0.81, -0.048, -0.76, -0.038]
tspan = (0, 50)

function f(u, p, t)
    x, y = u
    a, b, c, d = p
    dx = a*x -b*x*y
    dy = -c*y + d*x*y
    return [dx, dy]
end

prob1 = ODEProblem(f, u0, tspan, p)
sol1 = solve(prob1, Tsit5())

p1 = plot(sol1, title="Модель Лотки-Вольтерры", xlabel="Время", ylabel="Численность популяции", label=["жертвы" "хищники"])

p2 = plot(sol1, idxs=(1, 2), title="Фазовый портрет", xlabel="x, жертвы", ylabel="y, хищники", label="y от x")

x_s = p[3]/p[4]
y_s = p[1]/p[2]
u0_s = [x_s, y_s]

prob2 = ODEProblem(f, u0_s, tspan, p)
sol2 = solve(prob2, Tsit5())

p3 = plot(sol2, title="Модель Лотки-Вольтерры", xlabel="Время", ylabel="Численность популяции", label=["жертвы" "хищники"])

p4 = plot(sol2, idxs=(1, 2), title="Фазовый портрет", xlabel="x, жертвы", ylabel="y, хищники", label="y от x", xlimit = [0, 25], ylimit = [0, 25], lw = 5)

mkpath(plotsdir("lab05"))
savefig(p1, plotsdir("lab05", "case1_time_variant67.png"))
savefig(p2, plotsdir("lab05", "case1_phase_variant67.png"))
savefig(p3, plotsdir("lab05", "case2_time_variant67.png"))
savefig(p4, plotsdir("lab05", "case2_phase_variant67.png"))
