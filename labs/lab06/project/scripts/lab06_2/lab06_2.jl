using DrWatson
@quickactivate "project"
using OrdinaryDiffEq, Plots
default(fmt = :png)

N = 15089
I_0 = 95
R_0 = 45
S_0 = N - I_0 - R_0
u0 = [S_0, I_0, R_0]
p = [0.5, 0.1]
tspan = (0.0, 50.0)

function sir(u,p,t)
    (S,I,R) = u
    (α, β) = p
    dS = -α*S
    dI = α*S - β*I
    dR = β*I
    return [dS, dI, dR]
end

prob = ODEProblem(sir, u0, tspan, p)
sol = solve(prob, Tsit5(), saveat = 0.1)
p = plot(sol, label = ["S" "I" "R"])

mkpath(plotsdir("lab06_2"))
savefig(p, plotsdir("lab06_2", "lab06_2.png"))
