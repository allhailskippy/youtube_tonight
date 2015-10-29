# Source: http://ward.vandewege.net/blog/2011/04/acts_as_paranoid-and-acts_as_versioned-on-rails-3/
module ActiveRecord
  module Acts
    module Versioned
      def acts_as_paranoid_versioned(options = {})
        acts_as_paranoid
        acts_as_versioned options.merge({:association_options => {:dependent => nil}})

        # Override the destroy method. We want deleted records to end up in the versioned table,
        # not in the non-versioned table.
        self.class_eval do
          def destroy()
            with_transaction_returning_status do
              run_callbacks :destroy do
                # call the acts_as_paranoid delete function
                self.class.delete_all(:id => self.id)
                
                # get the 'deleted' object
                tmp = self.class.unscoped.find(self.id)
                
                # get the current version off of the 'deleted' record and augment it
                deleted_version = (tmp.send(tmp.class.version_column) || 0) + 1
                
                # Update the version on the 'deleted' object in the database
                tmp.class.unscoped.update_all({tmp.class.version_column => deleted_version}, :id => self.id)
                
                # Update object in memory
                tmp.send(:"#{tmp.class.version_column}=", deleted_version)
                self.send(:"#{tmp.class.version_column}=", deleted_version)
                
                # run it through the equivalent of acts_as_versioned's
                # save_version(). We used to call that function but it is a
                # noop when @saving_version is not set. That only gets done in
                # a protected function set_new_version(). Easier to just
                # replicate the meat of the save_version() function here.
                rev = tmp.class.versioned_class.new
                clone_versioned_model(tmp, rev)
                rev.send("#{tmp.class.version_column}=", deleted_version)
                rev.send("#{tmp.class.versioned_foreign_key}=", id)
                rev.send("#{tmp.class.ended_at_column}=", Time.now) if rev.respond_to?(tmp.class.ended_at_column)
                rev.save
                
                tmp.update_ended_at(rev)
                
                # set the paranoid_value field value
                self.paranoid_value = self.class.delete_now_value
              end
            end
          end
        end

        # protect the versioned model
        self.versioned_class.class_eval do
          def self.delete_all(conditions = nil); return; end
        end
      end
    end
  end
end
