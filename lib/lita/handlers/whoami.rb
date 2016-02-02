module Lita
  module Handlers
    class Whoami < Handler
      config :bots,      type: Array,  default: ['slackbot']
      config :redis_key, type: String, default: 'lita-whoami'

      route(/^(\w+) is (.+)/, :assign_person, command: true, help: {
        "SOMEONE is SOMETHING" => "Tell everbot that someone is something."
      })

      route(/^(\w+) isn['’‘]t (.+)/, :unassign_person, command: true, help: {
        "SOMEONE isn't SOMETHING" => "Tell everbot that someone is not something."
      })

      route(/^who ?is (\w+)/, :describe_person, command: true, help: {
        "who is PERSON" => "Everbot will tell you who somebody is."
      })

      route(/^(i|I) don['’‘]t know who anyone is/, :describe_everyone, command: true)

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
        return unless valid_thing?(thing, chat)

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

      def valid_thing?(thing, chat)
        return false if config.bots.include?(chat.message.source.user.name)

        true
      end

      Lita.register_handler(self)
    end
  end
end
