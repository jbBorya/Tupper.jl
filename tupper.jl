
using Pkg
Pkg.add("Suppressor")
Image = nothing
using Suppressor

function tupper_bitmap(k::BigInt)
    y_dr = divrem(fld(k, 17), 2)
    bin = []
    for i = 1:1802
        push!(bin, y_dr[2] == 1)
        y_dr = divrem(y_dr[1], 2)
    end
    return reshape(bin, (17, 106))
end

function visualize(bitmap)
    str = []
    for y = 1:17
        for x = 1:106
            push!(str, bitmap[y,107-x] ? 'X' : ' ')
        end
        push!(str, '\n')
    end
    return join(str)
end

function create_image(bitmap, col, type, file)
    img = Image.new("RGB", (17,106), "white")
    pixels = img.load()

    for y = 1:17
        for x = 1:106
            if bitmap[y,107-x]
                pixels[y,107-x] = col ? (Int64(trunc((y/17)*255)),Int64(trunc((x/106)*255)),100) : (0,0,0)
            end
        end
    end

    img.transpose(Image.ROTATE_90).save(file*"."*type)
end

function create_bin_file(bitmap, file)
end


params = Dict()
i = 1

while i < length(ARGS)
    global i
    if ARGS[i] == "--to-k"
        params["k"] = "NaN"
    else
        if ARGS[i] == "--from-k"
            params["k"] = ARGS[i+=1]
        elseif ARGS[i] == "--out"
            params["out"] = ARGS[i+=1]
        elseif ARGS[i] == "--in"
            params["in"] = ARGS[i+=1]
        elseif ARGS[i] == "--type"
            params["type"] = ARGS[i+=1]
        else
            exit(1)
        end
    end
    i += 1
end

if length(params) != 3
    exit(2)
end
if !haskey(params, "type")
    exit(3)
end
if !haskey(params, "k")
    exit(4)
end

if params["k"] == "NaN"
    if !haskey(params, "in")
        exit(5)
    end
else
    if !haskey(params, "out")
        exit(6)
    end

    try
        params["k"] = parse(BigInt, params["k"])
    catch cx
        exit(7)
    end
end

if params["type"] == "image" || params["type"] == "gay"
    @suppress begin
        global Image
        Pkg.add("PyCall")
        Pkg.add("Conda")
        using Conda
        Conda.add("Pillow")
        using PyCall
        Image = pyimport("PIL.Image")
    end
end

if typeof(params["k"]) == BigInt
    bitmap = tupper_bitmap(params["k"])
    if params["type"] == "text"
        print(visualize(bitmap))
    elseif params["type"] == "image"
        file_desc = split(params["out"], ".")
        @suppress create_image(bitmap, false, file_desc[2], file_desc[1])
    elseif params["type"] == "gay"
        file_desc = split(params["out"], ".")
        @suppress create_image(bitmap, true, file_desc[2], file_desc[1])
    end
end