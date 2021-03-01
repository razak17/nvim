local colors = require 'aesth.colors'

-- indicator_ok = '',
local icons_mode = {
    c      = {" 🅒 ", colors.plum3},
    ce     = {" 🅒 ", colors.plum3},
    cv     = {" 🅒 ", colors.plum3},
    i      = {" 🅘 ", colors.magenta},
    ic     = {" 🅘 ", colors.magenta},
    n      = {" 🅝 ", colors.SkyBlue2},
    no     = {" 🅝 ", colors.SkyBlue2},
    r      = {" 🅡 ", colors.chocolate},
    rm     = {" 🅡 ", colors.chocolate},
    R      = {" 🅡 ", colors.purple},
    Rv     = {" 🅡 ", colors.purple},
    s      = {" 🅢 ", colors.SkyBlue2},
    S      = {" 🅢 ", colors.SkyBlue2},
    t      = {" 🅣 ", colors.gray},
    V      = {" 🅥 ", colors.blue},
    v      = {" 🅥 ", colors.gray},
    ["r?"] = {" 🅡  ", colors.chocolate},
    [""] = {" 🅢 ", colors.SkyBlue2},
    [""] = {" 🅥 ", colors.blue},
    ["!"]  = {" !", colors.plum3}
}
    return icons_mode
