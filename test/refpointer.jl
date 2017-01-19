# This file is a part of Julia. License is MIT: http://julialang.org/license

x_notdefined = Ref{String}()
@test !isassigned(x_notdefined)

x_defined = Ref{String}("Test")
@test isassigned(x_defined)
