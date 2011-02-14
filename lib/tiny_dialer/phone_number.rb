module TinyDialerAdmin
  module PhoneNumber
    def self.parse(phone)
      if phone.to_s.size == 10
        phone.to_s.insert(3, "-").insert(7, "-")
      elsif phone.to_s.size == 11
        phone.to_s[1..-1].insert(3, "-").insert(7, "-")
      else
        phone
      end
    end
  end
end
