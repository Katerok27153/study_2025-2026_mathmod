using Graphs, GraphPlot, Random, Compose, Cairo, Fontconfig, Colors

Random.seed!(42)

N = 20
REMOVE_K = 5

NODE_SIZE_NORMAL = 0.002
NODE_SIZE_HUB = 0.004
EDGE_WIDTH = 2.0
LABEL_SIZE = 30
IMG_W = 500
IMG_H = 500

g_original = barabasi_albert(N, 2)
x, y = spring_layout(g_original)

function save_png(name, plot)
    img = compose(Compose.context(), Compose.rectangle(), fill("white"), plot)
    draw(PNG(name, IMG_W, IMG_H), img)
end

function report(title, g)
    comps = connected_components(g)
    largest = isempty(comps) ? 0 : maximum(length, comps)
    println(title)
    println("   Вершин:                 ", nv(g))
    println("   Рёбер:                  ", ne(g))
    println("   Компонент связности:    ", length(comps))
    println("   Крупнейшая компонента:  ", largest)
    println("   Плотность:              ", round(nv(g) <= 1 ? 0.0 : 2ne(g)/(nv(g)*(nv(g)-1)), digits=3))
    println()
end

degrees = [degree(g_original, v) for v in 1:nv(g_original)]
hubs = sortperm(degrees, rev=true)[1:REMOVE_K]
hubs_set = Set(hubs)

println("Хабы (топ-$REMOVE_K по степени): ", sort(hubs))

colors_orig = [v in hubs_set ? colorant"red" : colorant"deepskyblue" for v in 1:N]
sizes_orig = [v in hubs_set ? NODE_SIZE_HUB : NODE_SIZE_NORMAL for v in 1:N]

p1 = gplot(g_original, x, y,
    nodelabel=1:N,
    nodefillc=colors_orig,
    nodesize=sizes_orig,
    edgelinewidth=EDGE_WIDTH,
    nodelabelsize=LABEL_SIZE)
save_png("plots/1_original.png", p1)

non_hubs = collect(setdiff(1:N, hubs_set))
rand_vertices = shuffle(non_hubs)[1:REMOVE_K]
println("Удалённые случайные вершины: ", sort(rand_vertices))

remaining = sort(setdiff(1:N, rand_vertices))
mapping = Dict(old => new for (new, old) in enumerate(remaining))
g_rand = Graph(length(remaining))
for e in edges(g_original)
    v1, v2 = src(e), dst(e)
    if v1 in remaining && v2 in remaining
        add_edge!(g_rand, mapping[v1], mapping[v2])
    end
end

x_rand = [x[v] for v in remaining]
y_rand = [y[v] for v in remaining]
labels_rand = [string(v) for v in remaining]

remaining_hubs = [v for v in remaining if v in hubs_set]
colors_rand = [v in remaining_hubs ? colorant"red" : colorant"orange" for v in remaining]
sizes_rand = [v in remaining_hubs ? NODE_SIZE_HUB : NODE_SIZE_NORMAL for v in remaining]

p2 = gplot(g_rand, x_rand, y_rand,
    nodelabel=labels_rand,
    nodefillc=colors_rand,
    nodesize=sizes_rand,
    edgelinewidth=EDGE_WIDTH,
    nodelabelsize=LABEL_SIZE)
save_png("plots/2_random_deletion.png", p2)

println("Удалённые хабы: ", sort(hubs))

remaining_hubs_del = collect(setdiff(1:N, hubs))
mapping_hubs = Dict(old => new for (new, old) in enumerate(remaining_hubs_del))
g_hubs = Graph(length(remaining_hubs_del))
for e in edges(g_original)
    v1, v2 = src(e), dst(e)
    if v1 in remaining_hubs_del && v2 in remaining_hubs_del
        add_edge!(g_hubs, mapping_hubs[v1], mapping_hubs[v2])
    end
end

x_hubs = [x[v] for v in remaining_hubs_del]
y_hubs = [y[v] for v in remaining_hubs_del]
labels_hubs = [string(v) for v in remaining_hubs_del]

colors_hubs = fill(colorant"lightblue", length(remaining_hubs_del))
sizes_hubs = fill(NODE_SIZE_NORMAL, length(remaining_hubs_del))

p3 = gplot(g_hubs, x_hubs, y_hubs,
    nodelabel=labels_hubs,
    nodefillc=colors_hubs,
    nodesize=sizes_hubs,
    edgelinewidth=EDGE_WIDTH,
    nodelabelsize=LABEL_SIZE)
save_png("plots/3_targeted_deletion.png", p3)

println("\n✓ 1_original.png")
println("✓ 2_random_deletion.png")
println("✓ 3_targeted_deletion.png")

println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ ЭКСПЕРИМЕНТА")
println("="^60)

report("Исходная сеть:", g_original)
report("После случайного удаления:", g_rand)
report("После удаления хабов:", g_hubs)

println("\nИНТЕРПРЕТАЦИЯ:")
println("Если после удаления хабов крупнейшая компонента резко меньше")
println("или число компонент больше — сеть уязвима к целевым атакам.")
println("="^60)

println("\nФайлы сохранены:")
println("plots/1_original.png")
println("plots/2_random_deletion.png")
println("plots/3_targeted_deletion.png")
