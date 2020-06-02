module ViewComponentReflex
  class Component < ViewComponent::Base
    class << self
      def reflex(name, &blk)
        @stimulus_reflex.reflex(name, &blk)
      end

      def connect_stimulus_reflex
        @stimulus_reflex ||= Object.const_set(name + "Reflex", Class.new(StimulusReflex::Reflex) {
          include CableReady::Broadcaster

          def state
            session[element.dataset[:key]] ||= {}
          end

          define_singleton_method(:reflex) do |name, &blk|
            define_method(name) do |*args|
              instance_exec(*args, &blk)
            end
          end
        })
      end
    end

    def initialize
      @key = caller.find { |p| p.include? ".html.erb" }&.hash.to_s
    end

    def initialize_state(obj)
      @state = obj
      @state.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end

    def key
      if session[@key].nil?
        session[@key] = {}
        @state.each do |key, v|
          session[@key][key] = v
        end
      end
      @key
    end

    def state
      session[key]
    end
  end
end
