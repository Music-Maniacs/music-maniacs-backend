module UserStatHelper
  def user_stat
    @user_stat ||= current_user.user_stat if current_user.present?
  end
end