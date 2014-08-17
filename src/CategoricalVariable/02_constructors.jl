function CategoricalVariable(level::Integer, pool::CategoricalPool)
    return CategoricalVariable(convert(RefType, level), pool)
end
