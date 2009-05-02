DM PropertyManager is useful when you have like-models with identical properties between the two.

See examples below.

# Simple Example #

    class Rsvp
      include DataMapper::Resource
      include DataMapper::PropertyManager

      property :id, Serial

      manage(:seat) do
        belongs_to :room #some other model
  
        property :confirmation, String
        property :section, String
        property :number, String
      end
    end

    class Seat
      include DataMapper::Resource

      property :id, Serial
      property :sat_at, DateTime
    end

    @rsvp = Rsvp.new
    @rsvp.confirmation = "209fa9bj9jaa"
    @rsvp.section = "Orchestra"
    @rsvp.number  = "10A"
    @rsvp.save

    @seat = @rsvp.create_seat(:sat_at=>Time.now)
    @seat.section #=> "Orchestra"
    @seat.sat_at = "Fri May 01 21:18:24 -0700 2009"

  

# Delegation #
  



# Auto Archiver #
PropertyManager can be used to manage properties between a model and some archived version of the model
  
    class User
      include DataMapper::Resource
      include DataMapper::PropertyManager

      property :id,     Serial  
  
      manage(:archived_user) do
        property :name,   String
        property :email,  String
        property :password,  String
        property :created_at, DateTime
      end
  
      def archive!
        @au = create_archived_user
        @au.deleted_at = Time.now
        @au.save
        self.destroy
    
        @au
      end
  
    end

    class ArchivedUser
      include DataMapper::Resource
  
      def self.default_repository_name
        :my_archive_repository
      end
      property :id, Serial
      property :deleted_at, DateTime
    end

    user = User.new
    user.name = "Cory Odaniel"
    user.email = "propmanager@coryodaniel.com"
    user.password = "secretz"
    user.save

    # Move the user to the archive_users repo
    user.archive!