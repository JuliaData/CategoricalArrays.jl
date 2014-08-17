function OrdinalVariable(level::Integer, pool::OrdinalPool)
    return OrdinalVariable(convert(RefType, level), pool)
end
