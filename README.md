#Arpa

Arpa is an authorization library for Ruby or Ruby on Rails which restricts the accesses in controller and actions. Arpa  will help you to customize all permissions you need dynamically.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arpa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arpa

After you install Arpa and add it to your Gemfile, you need to run the generator:

    $ rails generate arpa:install
    
This command will create some files that are needed to run the Gem.

|    File  |     Purpose   |
|----------|:-------------:|
| db/migrate/20140120201010_create_arpa_tables.rb |  Migration to create the all **Arpa** tables in your database (your name will include a different timestamp) |
| config/locales/arpa.en.yml |  Locales to use in Arpa classes |

**Obs.:** The migration file will create a associate table between **Arpa::Profile** and **SomeModel**. By **default** the model is **User** as **users** table. The model to associate must exist in your Application before run that generate.

If you want a different Model to associate with Arpa::Profile you can pass some arguments:  

    $ rails generate arpa:install [ASSOCIATE_TABLE] [ASSOCIATE_PRIMARY_KEY]

####Eg. 1:

    $ rails generate arpa:install admins
    
That command will create the association with **admins** table with **admin_id** as foreign key.

####Eg. 2:

    $ rails generate arpa:install admins admin_custom_id
    
That command will create the association with **admins** table with **admin_custom_id** as foreign key.


After run the generate command, you need to run the migration to create all Arpa tables:

    $ rake db:migrate

---

Arpa can generate the *Controllers*, *Views*, *Stylesheet* and *Routes* to a basic CRUD for *resources*, *roles* and *profiles*. To do that you can run:

    $ rails generate arpa:controllers
    
This command will create some files.

|    File  |     Purpose   |
|----------|:-------------:|
| app/assets/stylesheets/arpa/arpa_accordion.scss |  Basic stylesheet to use with Arpa views |
| app/controllers/arpa/resources_controller.rb  app/controllers/arpa/roles_controller.rb  app/controllers/arpa/profiles_controller.rb | Controllers to use the CRUD actions for each one |
| app/views/arpa/resources/  app/controllers/arpa/roles/  app/controllers/arpa/profiles/ | All views to use the CRUD actions for each controller above |
| config/routes.rb |  Will add all routes into this file with all resources of Arpa |


## Usage

First of all you must create the Resources, Roles and Profiles (each is avaliable in the paths listed in a section bellow). After that you need associate **Arpa::Profile** with **SomeModel** (to do this, you need create by your own the associate form view, saving some profiles in some model). Done that you can use some Helpers generated by Arpa.

### Association between Arpa::Profile and SomeModel

You just need have a method called **:profile_ids** inside the **SomeModel** model. This method should return a list of ids from profiles associated in the model.

You just add a HBTM association in SomeModel model:

```ruby
class User < ActiveRecord::Base
	has_and_belongs_to_many :profiles, class_name: 'Arpa::Repositories::Profiles::RepositoryProfile'
end
```
With this you will be able to use the :profile_ids method.

If the Model name is different on database you need add the **foreign_key** option:

```ruby
class User < ActiveRecord::Base
	self.table_name = 'admins'

	has_and_belongs_to_many :profiles, class_name: 'Arpa::Repositories::Profiles::RepositoryProfile', foreign_key: 'admin_id'
end
```

### Controller helpers

Arpa will create some helpers to use inside your controllers and views.

To verify if a user has access to some :controler and :action, use the following helper:

```ruby
has_access?('users', 'index')
```


**Obs.:** To that helper method works. You must have **:current_user** attribute or method.

---
If you want use that methods inside another object you should use the **Arpa::Services::Verifier** class;

You just need pass as arguments the :session and :current_user:

```ruby
verifier = Arpa::Services::Verifier.new(current_user)
verifier.has_access?('users', 'index')
```

### Controller Filter

If you want create a filter to verify if the current_user has access and if not redirect to another route you can do this:

Create a method in ApplicationController and add as a before_filter callback from rails:

```ruby
class ApplicationController < ActionController::Base
	before_filter :authorize_user  
	
	 def authorize_user
      controller = params[:controller]
      action     = params[:action]		
      redirect_to some_url unless has_access?(controller, action)
	 end

end  
```

**Obs. 1:** The **has_access?** method come from Controller Helper method which Arpa gem has been created.

**Obs. 2:** When you create the **before_filter** you probably wanna skip that callback in somes **controllers** (like login or devise controllers). To do this you need set the **skip_before_action** passing as parameter the name of before_filter method as you can see bellow:

```ruby
  skip_before_action :authorize_user
```


## Descriptions Locales for Arpa::Entities::Action

Arpa will use on **description** method from Arpa::Entities::Action a specific Locale.

You should create a locale file to print correctly the descriptions of the actions.

####Eg.:

```ruby
en:
  entities:
    resources:
      users: #Here is the name of controller
        actions:
          description:
            #Here is each action of the controller
            index:   'List of Users'
            show:    'Show of User'
            new:     'Access to registration form of User'
            edit:    'Access to change form of User'
            create:  'Perform action registering of User'
            update:  'Perform action update of User'
            destroy: 'Perform action destroy of User'

```

## Information

Arpa will add a new column called **is_arpa_admin** as boolean in the associate table with value **false** as default. You must set some user (creating a migration for example), with *is_arpa_admin* as **true** to navigate between the views without be catched by the filter verification.

If you want a **action** of some **Controller** pass without permission on *before_filter* callback. You just need start the name of action with underscode ('_'). For example:

```ruby
  def _some_free_action_which_not_need_permission
  end
```


The routes created by **arpa:controllers** generator will be able to access some paths for each Controller created:

```ruby
generate_resources_and_actions_resources GET    /resources/generate_resources_and_actions(.:format) arpa/resources#generate_resources_and_actions
                               resources GET    /resources(.:format)                                arpa/resources#index
                                         POST   /resources(.:format)                                arpa/resources#create
                            new_resource GET    /resources/new(.:format)                            arpa/resources#new
                           edit_resource GET    /resources/:id/edit(.:format)                       arpa/resources#edit
                                resource GET    /resources/:id(.:format)                            arpa/resources#show
                                         PATCH  /resources/:id(.:format)                            arpa/resources#update
                                         PUT    /resources/:id(.:format)                            arpa/resources#update
                                         DELETE /resources/:id(.:format)                            arpa/resources#destroy
                                         DELETE /roles/:id(.:format)                                arpa/roles#remove
                                   roles GET    /roles(.:format)                                    arpa/roles#index
                                         POST   /roles(.:format)                                    arpa/roles#create
                                new_role GET    /roles/new(.:format)                                arpa/roles#new
                               edit_role GET    /roles/:id/edit(.:format)                           arpa/roles#edit
                                    role GET    /roles/:id(.:format)                                arpa/roles#show
                                         PATCH  /roles/:id(.:format)                                arpa/roles#update
                                         PUT    /roles/:id(.:format)                                arpa/roles#update
                                         DELETE /roles/:id(.:format)                                arpa/roles#destroy
                                         DELETE /profiles/:id(.:format)                             arpa/profiles#remove
                                profiles GET    /profiles(.:format)                                 arpa/profiles#index
                                         POST   /profiles(.:format)                                 arpa/profiles#create
                             new_profile GET    /profiles/new(.:format)                             arpa/profiles#new
                            edit_profile GET    /profiles/:id/edit(.:format)                        arpa/profiles#edit
                                 profile GET    /profiles/:id(.:format)                             arpa/profiles#show
                                         PATCH  /profiles/:id(.:format)                             arpa/profiles#update
                                         PUT    /profiles/:id(.:format)                             arpa/profiles#update
                                         DELETE /profiles/:id(.:format)                             arpa/profiles#destroy
```

## License

MIT License. Copyright Rachid Calazans.
