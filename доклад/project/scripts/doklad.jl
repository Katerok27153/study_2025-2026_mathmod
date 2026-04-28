using Graphs, GraphPlot, Random, Compose, Cairo, Fontconfig, Colors

Random.seed!(42)

N = 20
REMOVE_K = 5

NODE_SIZE = 0.002
EDGE_WIDTH = 2.0
LABEL_SIZE = 30
IMG_W = 500
IMG_H = 500

g = barabasi_albert(N, 2)

x, y = spring_layout(g)

function largest_comp_size(g)
    comps = connected_components(g)
    isempty(comps) ? 0 : maximum(length, comps)
end

function components_count(g)
    length(connected_components(g))
end

function density_graph(g)
    nv(g) <= 1 && return 0.0
    2ne(g) / (nv(g)*(nv(g)-1))
end

function save_png(name, plot)
    img = compose(
        Compose.context(),
        Compose.rectangle(),
        fill("white"),
        plot
    )
    draw(PNG(name, IMG_W, IMG_H), img)
end

function keep_coords(vec, removed)
    inds = setdiff(1:length(vec), removed)
    vec[inds]
end

function report(title, g)
    println(title)
    println("   Вершин:                 ", nv(g))
    println("   Рёбер:                  ", ne(g))
    println("   Компонент связности:    ", components_count(g))
    println("   Крупнейшая компонента:  ", largest_comp_size(g))
    println("   Плотность:              ", round(density_graph(g), digits=3))
    println()
end

g_rand = copy(g)
rand_vertices = shuffle(collect(1:N))[1:REMOVE_K]

println("Удалённые случайные вершины: ", rand_vertices)

for v in sort(rand_vertices, rev=true)
    rem_vertex!(g_rand, v)
end

x_rand = keep_coords(x, rand_vertices)
y_rand = keep_coords(y, rand_vertices)

g_hubs = copy(g)

degrees = [degree(g_hubs, v) for v in 1:nv(g_hubs)]
hubs = sortperm(degrees, rev=true)[1:REMOVE_K]

println("Удалённые хабы: ", hubs)

for v in sort(hubs, rev=true)
    rem_vertex!(g_hubs, v)
end

x_hubs = keep_coords(x, hubs)
y_hubs = keep_coords(y, hubs)

println("\nСохраняем изображения...")

# Исходный
p1 = gplot(
    g, x, y,
    nodelabel=1:nv(g),
    nodefillc=colorant"deepskyblue",
    nodesize=NODE_SIZE,
    edgelinewidth=EDGE_WIDTH,
    nodelabelsize=LABEL_SIZE
)

save_png("plots/1_original.png", p1)

# Случайное удаление
p2 = gplot(
    g_rand, x_rand, y_rand,
    nodelabel=1:nv(g_rand),
    nodefillc=colorant"orange",
    nodesize=NODE_SIZE,
    edgelinewidth=EDGE_WIDTH,
    nodelabelsize=LABEL_SIZE
)

save_png("plots/2_random_deletion.png", p2)

# Удаление хабов
p3 = gplot(
    g_hubs, x_hubs, y_hubs,
    nodelabel=1:nv(g_hubs),
    nodefillc=colorant"red",
    nodesize=NODE_SIZE,
    edgelinewidth=EDGE_WIDTH,
    nodelabelsize=LABEL_SIZE
)

save_png("plots/3_targeted_deletion.png", p3)

println("✓ 1_original.png")
println("✓ 2_random_deletion.png")
println("✓ 3_targeted_deletion.png")

println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ ЭКСПЕРИМЕНТА")
println("="^60)

report("Исходная сеть:", g)
report("После случайного удаления:", g_rand)
report("После удаления хабов:", g_hubs)

println("ИНТЕРПРЕТАЦИЯ:")
println("Если после удаления хабов крупнейшая компонента резко меньше")
println("или число компонент больше — сеть уязвима к целевым атакам.")
println("="^60)

println("\nФайлы сохранены:")
println("plots/1_original.png")
println("plots/2_random_deletion.png")
println("plots/3_targeted_deletion.png")
