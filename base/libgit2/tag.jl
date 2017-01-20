# This file is a part of Julia. License is MIT: http://julialang.org/license

function tag_list(repo::GitRepo)
    sa_ref = Ref(StrArrayStruct())
    @check ccall((:git_tag_list, :libgit2), Cint,
                 (Ptr{StrArrayStruct}, Ptr{Void}), sa_ref, repo.ptr)
    res = convert(Vector{String}, sa_ref[])
    free(sa_ref)
    return res
end

function tag_delete(repo::GitRepo, tag::AbstractString)
    @check ccall((:git_tag_delete, :libgit2), Cint,
                  (Ptr{Void}, Cstring, ), repo.ptr, tag)
end

function tag_create(repo::GitRepo, tag::AbstractString, commit::Union{AbstractString,GitHash};
                    msg::AbstractString = "",
                    force::Bool = false,
                    sig::Signature = Signature(repo))
    oid_ptr = Ref(GitHash())
    commit_obj = get(GitCommit, repo, commit)
    commit_obj === nothing && return oid_ptr[] # return empty oid
    git_sig = convert(GitSignature, sig)
    @check ccall((:git_tag_create, :libgit2), Cint,
         (Ptr{GitHash}, Ptr{Void}, Cstring, Ptr{Void}, Ptr{SignatureStruct}, Cstring, Cint),
          oid_ptr, repo.ptr, tag, commit_obj.ptr, git_sig.ptr, msg, Cint(force))
    return oid_ptr[]
end

function name(tag::GitTag)
    str_ptr = ccall((:git_tag_name, :libgit2), Cstring, (Ptr{Void}, ), tag.ptr)
    if str_ptr == C_NULL
        throw(Error.GitError(Error.ERROR))
    else
        return unsafe_string(str_ptr)
    end
end

function target(tag::GitTag)
    oid_ptr = ccall((:git_tag_target_id, :libgit2), Ptr{GitHash}, (Ptr{Void}, ), tag.ptr)
    if oid_ptr == C_NULL
        throw(Error.GitError(Error.ERROR))
    else
        return GitHash(oid_ptr)
    end
end

Base.show(io::IO, tag::GitTag) = print(io, "GitTag:\nTag name: $(name(tag)) target: $(target(tag))")
