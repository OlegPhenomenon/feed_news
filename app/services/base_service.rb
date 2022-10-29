module BaseService
  def struct_object(**kwargs)
    Struct.new(:success?, :instance, :errors)
          .new(kwargs[:success], kwargs[:instance], kwargs[:errors])
  end
end
