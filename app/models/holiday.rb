require 'twitter'

class Holiday < ActiveRecord::Base

  class << self
    def tweet
      today = Date.today
      return if today.wday == 0 || today.wday == 6

      account = Account.first()
      return if account.nil?

      prev_day = where(["holiday_at = ?", today - (today.wday == 1 ? 3 : 1)]).first
      return if prev_day.nil?

      next_day = where(["holiday_at >= ?", today]).first
      return if next_day.nil?

      diff = next_day.holiday_at - today
      diff_name = "%d日後" % diff
      case diff
      when 0
        return
      when 1
        diff_name = "明日"
      end

      status = "前回の祝日は、%sでした。次の祝日は、%sの『%s』です。" % [prev_day.name, diff_name, next_day.name]

      puts status
      return 
      response = Twitter.access_token(account).post(
        '/statuses/update.json',
        { :status => status }
      )

      case response
      when Net::HTTPSuccess
        logger.info "Posted"
      else
        logger.error "Failed to post status"
      end
    end
  end
end
