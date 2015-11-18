module Lita
  module Handlers
    class Whoami < Handler
      REDIS_KEY = 'lita-whoami'

      route(/^(\w+) is (.+)/, :assign_person, command: true, help: {
        "SOMEONE is SOMETHING" => "Tell everbot that someone is something."
      })

      route(/^who ?is (\w+)/, :describe_person, command: true, help: {
        "who is PERSON" => "Everbot will tell you who somebody is."
      })

      def key_for_person name
        "#{REDIS_KEY}:#{name}"
      end

      def assign_person(chat)
        name, thing = chat.matches[0]

        return if name == 'who'

        redis.rpush key_for_person(name), thing

        chat.reply "Okay, #{name} is #{thing}!"
      end

      def describe_person(chat)
        name = chat.matches[0][0]

        descriptors = redis.lrange(key_for_person(name), 0, -1).uniq

        chat.reply "#{name} is #{descriptors.join ', '}"
      end

      Lita.register_handler(self)
    end
  end
end
