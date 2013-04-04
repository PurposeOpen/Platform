module RulesSerializable
  def self.included(model)
    model.after_initialize :deserialize_rules
  end

  def rules
    @rules ||= begin
      result = read_attribute(:rules)
      result.present? ? result : write_attribute(:rules, result = [])
      result
    end
  end

  def add_rule(rule_type, args)
    rule_class = (ListCutter.name + "::" + rule_type.to_s.camelcase).constantize
    rules << rule_class.new(args.merge(movement: movement))
    write_attribute :rules, rules
  end

  def deserialize_rules
    return if self.rules.blank? || self.rules.first.is_a?(ListCutter::Rule)
    rules_clone = self.rules.clone
    self.rules.clear
    rules_clone.each do |r|
      r.each do |k, v|
        add_rule k, v
      end
    end
  end
end