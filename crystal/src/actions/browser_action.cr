abstract class BrowserAction < Lucky::Action
  include Lucky::ProtectFromForgery
  accepted_formats [:html, :json], default: :html

  # This module provides current_user, sign_in, and sign_out methods
  include Authentic::ActionHelpers(User)

  # When testing you can skip normal sign in by using `visit` with the `as` param
  #
  # flow.visit Me::Show, as: UserFactory.create
  include Auth::TestBackdoor

  # By default all actions that inherit 'BrowserAction' require sign in.
  #
  # You can remove the 'include Auth::RequireSignIn' below to allow anyone to
  # access actions that inherit from 'BrowserAction' or you can
  # 'include Auth::AllowGuests' in individual actions to skip sign in.
  include Auth::RequireSignIn

  # `expose` means that `current_user` will be passed to pages automatically.
  #
  # In default Lucky apps, the `MainLayout` declares it `needs current_user : User`
  # so that any page that inherits from MainLayout can use the `current_user`
  expose current_user

  SIGNED_IN_COOKIE = "signed-in"

  private def cache_friendly_sign_in(user : User) : Void
    sign_in(user)
    cookies.set_raw(SIGNED_IN_COOKIE, "1") # Varnish uses this to know if the user is logged in
  end

  private def cache_friendly_sign_out : Void
    sign_out
    cookies.delete(SIGNED_IN_COOKIE) if cookies.get_raw?(SIGNED_IN_COOKIE)
  end

  # This method tells Authentic how to find the current user
  private def find_current_user(id) : User?
    UserQuery.new.id(id).first?
  end

  private def cache_in_varnish(duration : Time::Span)
    if current_user.nil?
      response.headers["Cache-Control"] = "s-maxage=#{duration.to_i}, public"
    end
    continue
  end

  private def cache_publicly(duration : Time::Span)
    response.headers["Cache-Control"] = "max-age=#{duration.to_i}, public"
    continue
  end

  private def weak_etag(last_modified : Int64)
    # No ETag for logged in users
    if current_user.nil?
      unconditional_weak_etag(last_modified)
    end

    continue
  end

  private def unconditional_weak_etag(last_modified : Int64)
    response.headers["ETag"] = "W/#{last_modified}-#{ReadRust::Config.revision}"

    continue
  end
end
