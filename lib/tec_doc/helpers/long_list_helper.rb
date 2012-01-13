module Helpers
  module LongListHelper
    # Create array with hashes for tec docs longlist parameters
    def array_to_batch_list(array, batch_limit=25)
      array.each_slice(batch_limit).to_a.map do |batch|
        batch.inject({}) do |long_list, id|
          long_list["id_#{id}"] = id
          long_list
        end
      end
    end
  end
end
