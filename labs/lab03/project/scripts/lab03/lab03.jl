using Pkg
Pkg.activate("../project")
using DrWatson
@quickactivate "project"
using DifferentialEquations
using Plots
default(fmt = :png)
using DataFrames
using JLD2

script_name = "lab03"
mkpath(plotsdir(script_name))

### Начальные данные

x0 = 44200
y0 = 54100
p1 = [0.312, 0.456, 0.256, 0.34]
p2 = [0.318, 0.615, 0.312, 0.512]
tspan = (0,1)

### Случай 1. Модель боевых действий между регулярными войсками

function f1(u,p,t)
	x,y = u
	a,b,c,h = p
	dx = -a*x-b*y + sin(t + 3)
	dy = -c*x-h*y + cos(t + 7)
	return [dx, dy]
end

### Случай 2. Модель ведение боевых действий с участием регулярных войск и партизанских отрядов

function f2(u,p,t)
	x,y = u
	a,b,c,h = p
	dx = -a*x-b*y + abs(cos(8*t))
	dy = -c*x*y-h*y + abs(sin(6*t))
	return [dx, dy]
end

### График 1. Модель боевых действий между регулярными войсками

problem1 = ODEProblem(f1, [x0,y0], tspan, p1)
sol1 = solve(problem1, Tsit5())
plot1 = plot(sol1, title = "Модель боевых действий №1", label = ["Армия X" "Армия Y"], xaxis = "t, время", yaxis = "Численность армии")
display(plot1)

### График 2. Модель ведение боевых действий с участием регулярных войск и партизанских отрядов

problem2 = ODEProblem(f2, [x0,y0], tspan, p2)
sol2 = solve(problem2, Tsit5())
plot2 = plot(sol2, title = "Модель боевых действий №2", label = ["Армия X" "Армия Y"], xaxis = "t, время", yaxis = "Численность армии")
display(plot2)

savefig(plot1, plotsdir(script_name, "result1.png"))
savefig(plot2, plotsdir(script_name, "result2.png"))
