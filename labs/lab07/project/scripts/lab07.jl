# ## Эффективность рекламы. Вариант 67

# Инициализация проекта
using DrWatson
@quickactivate "project"
using OrdinaryDiffEq, Plots
default(fmt = :png)

# Уравнения, описывающие распростронение рекламы
f(n, p, t) = (p[1] + p[2]*n)*(p[3] - n)
f3(n, p, t) = (p[1]*sin(t) + p[2]*t*n)*(p[3]-n)

# Начальные условия
N=1670
p1 = [0.133, 0.000033, N]
p2 = [0.0000132, 0.32, N]
p3 = [0.8, 0.15, N]
n_0 = 12

tspan1 = (0.0, 20.0)
tspan2 = (0.0, 0.04)
tspan3 = (0.0, 1.0)

prob1 = ODEProblem(f, n_0, tspan1, p1)
prob2 = ODEProblem(f, n_0, tspan2, p2)
prob3 = ODEProblem(f3, n_0, tspan3, p3)

# Решение и построение графика для 1-ого случая: $\frac{dn}{dt} = (0.133 + 0.000033*n(t))(N - n(t))$
sol1 = solve(prob1, Tsit5(), saveat = 0.01)
p1 = plot(sol1, yaxis = "N(t)", label="n")

# Решение и построение графика для 2-ого случая: $\frac{dn}{dt} = (0.0000132 + 0.32*n(t))(N - n(t))$
sol2 = solve(prob2, Tsit5(), saveat = 0.0001)

# Поиск максимального значения для случая 2
dev = [sol2(i, Val{1}) for i in 0:0.0001:0.04]
println("Максимальное значение: ", maximum(dev))

findall(x -> x == maximum(dev), dev)
println("Индексы максимума: ", findall(x -> x == maximum(dev), dev))

x = sol2.t[94]
y = sol2.u[94]

p2 = plot(sol2, yaxis="N(t)", label="n")
scatter!((x,y), leg=:bottomright, label="максимальная скорость")

# Решение и построение графика для 3-ого случая: $\frac{dn}{dt} = (0.8*t + 0.15*sin(t)*n(t))(N - n(t))$
sol3 = solve(prob3, Tsit5(), saveat = 0.0001)
p3 = plot(sol3, markersize =:15, yaxis="N(t)", label="n")

# Сохранение результатов
mkpath(plotsdir("lab07"))
savefig(p1, plotsdir("lab07", "lab07_1.png"))
savefig(p2, plotsdir("lab07", "lab07_2.png"))
savefig(p3, plotsdir("lab07", "lab07_3.png"))
