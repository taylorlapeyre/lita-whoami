module Lita
  module Handlers
    class Whoami < Handler
      config :bots,      type: Array,  default: ['slackbot']
      config :redis_key, type: String, default: 'lita-whoami'

      route(/^(\w+) is (.+)/, :assign_person, command: true, help: {
        "SOMEONE is SOMETHING" => "Make someone be something."
      })

      route(/^(\w+) isn['’‘]t (.+)/, :unassign_person, command: true, help: {
        "SOMEONE isn't SOMETHING" => "Make someone not longer be something."
      })

      route(/^who ?is (\w+)/, :describe_person, command: true, help: {
        "who is PERSON" => "Tells you who somebody is."
      })

      route(/^(i|I) don['’‘]t know who anyone is/, :describe_everyone, command: true, help: {
        "I don't know who anyone is" => "Tells you who everyone is."
      })

      def key_for_person name
        "#{config.redis_key}:#{name.downcase}"
      end

      def describe_everyone(chat)
        chat.reply redis.keys(config.redis_key + '*')
          .map { |key| key.split(':').last }
          .map { |person| person + " is " + get_descriptiors_for(person).join(', ') }
          .join("\n\n")
      end

      def assign_person(chat)
        name, thing = chat.matches[0]

        return if name == 'who'
        return if invalid_thing?(thing, chat)

        redis.rpush key_for_person(name), thing

        chat.reply "Okay, #{name} is #{thing}!"
      end

      def unassign_person(chat)
        name, thing = chat.matches[0]

        return if name == 'who'

        redis.lrem key_for_person(name), 0, thing

        chat.reply "Okay, #{name} is not #{thing}."
      end

      def describe_person(chat)
        name = chat.matches[0][0]

        descriptors = get_descriptiors_for(name)

        chat.reply "#{name} is #{descriptors.join ', '}"
      end

      def get_descriptiors_for(name)
        redis.lrange(key_for_person(name), 0, -1).uniq
      end

      def invalid_thing?(thing, chat)
        return true if chat.message.body.include? 'currently in Do Not Disturb mode'
        return true if config.bots.include?(chat.message.source.user.name)

        false
      end

      Lita.register_handler(self)
    end
  end
end
