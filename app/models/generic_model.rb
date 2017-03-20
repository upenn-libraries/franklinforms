# Reference: http://stackoverflow.com/a/13590910

class GenericModel < OpenStruct
  include ActiveModel::Validations
  extend ActiveModel::Naming
end
