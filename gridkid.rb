# This file creates a grid spreadsheet to evaluate expressions and parse through
# via a tree like structure environment to return desired values
# Created by: Cameron Harmon
# Test case apparatus generated with help from ChatGPT

# Expression abstraction for holding a variety of values together
class Expression
  def initialize(value)
    @value = value
  end

  def evaluate(env)
    raise "Subclasses must implement the evaluate method"
  end

  def to_string
    raise "Subclasses must implement the to_string method"
  end
end

# Environment abstraction for accessing the grid
class Environment
  attr_accessor :grid

  def initialize(grid)
    @grid = grid
  end

  def get(address)
    result = grid.get_cell(address).evaluate(self)
    if result.is_a?(Primitive)
      return result
    else
      raise "Error: Somehow didn't result in Primitive type"
    end
  end
end

# Grid abstraction for holding cells of expressions
class Grid
  attr_reader :maxRows
  attr_reader :maxColumns

  def initialize(rows, columns)
    @cells = Array.new(rows) { Array.new(columns)}
    @maxRows = rows
    @maxColumns = columns
  end

  def set_cell(address, expression)
    if address.is_a?(CellLvalue)
      if ((address.row >= @maxRows || address.row < 0) || 
        (address.row >= @maxRows || address.row < 0 )) || 
        ((address.column >= @maxColumns || address.column < 0) || 
        (address.column >= @maxColumns || address.column < 0))
        raise "Provided address out of bounds"
      else
        @row = address.row
        @column = address.column
        @cells[@row][@column] = expression
      end
    else
      raise "Not a CellLvalue"
    end
  end

  def get_cell(address)
    if address.is_a?(CellLvalue)
      if ((address.row >= @maxRows || address.row < 0) || 
        (address.row >= @maxRows || address.row < 0 )) || 
        ((address.column >= @maxColumns || address.column < 0) || 
        (address.column >= @maxColumns || address.column < 0))
        raise "Provided address out of bounds"
      else
        row = address.row
        column = address.column
      end
      # Evaluate the cell's expression using the provided environment
      expression = @cells[row][column]
      return expression
    else
      raise "Not a CellLvalue"
    end
  end
end

# Abstraction class for primitives that inherits from Expression
class Primitive < Expression
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def to_string
    @value.to_s
  end
end

# Dependent classes that use Primitive, this is our desired outputs for evaluate!!
class IntegerPrimitive < Primitive
  def initialize(value)
    begin
      @value = Integer(value)
    rescue ArgumentError
      raise "Invalid integer value: #{value}"
    end
  end

  def evaluate(env)
    self
  end

  def to_string
    @value.to_s
  end
end

class FloatPrimitive < Primitive
  def initialize(value)
    begin
      @value = Float(value)
    rescue ArgumentError
      raise "Invalid float value: #{value}"
    end
  end

  def evaluate(env)
    self
  end

  def to_string
    @value.to_s
  end
end

class BooleanPrimitive < Primitive
  def initialize(value)
    if value == true || value == false
      @value = !!value
    else
      raise "Invalid boolean value: #{value}"
    end
  end

  def evaluate(env)
    self
  end

  def to_string
    if @value == true
      return "true"
    else
      return "false"
    end
  end
end

class StringPrimitive < Primitive
  def initialize(value)
    if value.is_a?(String)
      @value = value.to_s
    else
      raise "Invalid string value: #{value}"
    end
  end

  def evaluate(env)
    self
  end

  def to_string
    @value
  end
end

# Dependent classes of expressions
class Add < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value + @r.value
      return IntegerPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value + @r.value
      return FloatPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value + rightCast.value
      return FloatPrimitive.new(result)
    else
      raise "Type error in addition"
    end
  end

  def to_string
    "(#{@left.to_string} + #{@right.to_string})"
  end
end

class Subtract < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value - @r.value
      return IntegerPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value - @r.value
      return FloatPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value - rightCast.value
      return FloatPrimitive.new(result)
    else
      raise "Type error in subtraction"
    end
  end

  def to_string
    "(#{@left.to_string} - #{@right.to_string})"
  end
end

class Multiply < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value * @r.value
      return IntegerPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value * @r.value
      return FloatPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value * rightCast.value
      return FloatPrimitive.new(result)
    else
      raise "Type error in multiplication"
    end
  end

  def to_string
    "(#{@left.to_string} * #{@right.to_string})"
  end
end

class Divide < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @r == 0
      raise "Division by zero not allowed"
    end
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value / @r.value
      return IntegerPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value / @r.value
      return FloatPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value / rightCast.value
      return FloatPrimitive.new(result)
    else
      raise "Type error in division"
    end
  end

  def to_string
    "(#{@left.to_string} / #{@right.to_string})"
  end
end

class Modulo < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)

    if @r == 0
      raise "Modulus by zero not allowed"
    end
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value % @r.value
      return IntegerPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value % @r.value
      return FloatPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value % rightCast.value
      return FloatPrimitive.new(result)
    else
      raise "Type error in modulus"
    end
  end

  def to_string
    "(#{@left.to_string} % #{@right.to_string})"
  end
end

class Exponent < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value ** @r.value
      return IntegerPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value ** @r.value
      return FloatPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value ** rightCast.value
      return FloatPrimitive.new(result)
    else
      raise "Type error in exponentiation"
    end
  end

  def to_string
    "(#{@left.to_string} ** #{@right.to_string})"
  end
end

class Equals < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value == @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value == @r.value
      return BooleanPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value == rightCast.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(BooleanPrimitive) && @r.is_a?(BooleanPrimitive)
      result = @l.value == @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(StringPrimitive) && @r.is_a?(StringPrimitive)
      result = @l.value == @r.value
      return BooleanPrimitive.new(result)
    else
      raise "Type error in equals"
    end
  end

  def to_string
    "(#{@left.to_string} == #{@right.to_string})"
  end
end

class NotEquals < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value != @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value != @r.value
      return BooleanPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value != rightCast.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(BooleanPrimitive) && @r.is_a?(BooleanPrimitive)
      result = @l.value != @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(StringPrimitive) && @r.is_a?(StringPrimitive)
      result = @l.value != @r.value
      return BooleanPrimitive.new(result)
    else
      raise "Type error in not equals"
    end
  end

  def to_string
    "(#{@left.to_string} != #{@right.to_string})"
  end
end

class LessThan < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value < @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value < @r.value
      return BooleanPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value < rightCast.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(StringPrimitive) && @r.is_a?(StringPrimitive)
      result = @l.value <=> @r.value
      if result < 0
        return BooleanPrimitive.new(true)
      else
        return BooleanPrimitive.new(false)
      end
    else
      raise "Type error in less than"
    end
  end

  def to_string
    "(#{@left.to_string} < #{@right.to_string})"
  end
end

class LessThanOrEqual < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value <= @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value <= @r.value
      return BooleanPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value <= rightCast.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(StringPrimitive) && @r.is_a?(StringPrimitive)
      result = @l.value <=> @r.value
      if result <= 0
        return BooleanPrimitive.new(true)
      else
        return BooleanPrimitive.new(false)
      end
    else
      raise "Type error in less than or equal"
    end
  end

  def to_string
    "(#{@left.to_string} <= #{@right.to_string})"
  end
end

class GreaterThan < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value > @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value > @r.value
      return BooleanPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value > rightCast.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(StringPrimitive) && @r.is_a?(StringPrimitive)
      result = @l.value <=> @r.value
      if result > 0
        return BooleanPrimitive.new(true)
      else 
        return BooleanPrimitive.new(false)
      end
    else
      raise "Type error in greater than"
    end
  end

  def to_string
    "(#{@left.to_string} > #{@right.to_string})"
  end
end

class GreaterThanOrEqual < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value >= @r.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(FloatPrimitive) && @r.is_a?(FloatPrimitive)
      result = @l.value >= @r.value
      return BooleanPrimitive.new(result)
    elsif (@l.is_a?(FloatPrimitive) && @r.is_a?(IntegerPrimitive)) || (@l.is_a?(IntegerPrimitive) && @r.is_a?(FloatPrimitive))
      leftCast = IntToFloat.new(@l).evaluate(env)
      rightCast = IntToFloat.new(@r).evaluate(env)
      result = leftCast.value >= rightCast.value
      return BooleanPrimitive.new(result)
    elsif @l.is_a?(StringPrimitive) && @r.is_a?(StringPrimitive)
      result = @l.value <=> @r.value
      if result >= 0 
        return BooleanPrimitive.new(true)
      else 
        return BooleanPrimitive.new(false)
      end
    else
      raise "Type error in greater than or equal"
    end
  end

  def to_string
    "(#{@left.to_string} >= #{@right.to_string})"
  end
end

class And < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(BooleanPrimitive) && @r.is_a?(BooleanPrimitive)
      result = @l.value && @r.value
      return BooleanPrimitive.new(result)
    else
      raise "Type error in boolean and"
    end
  end

  def to_string
    "(#{@left.to_string} && #{@right.to_string})"
  end
end

class Or < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(BooleanPrimitive) && @r.is_a?(BooleanPrimitive)
      result = @l.value || @r.value
      return BooleanPrimitive.new(result)
    else
      raise "Type error in boolean or"
    end
  end

  def to_string
    "(#{@left.to_string} || #{@right.to_string})"
  end
end

class Not < Expression
  def initialize(value)
    @value = value
  end

  def evaluate(env)
    @v = @value.evaluate(env)
    
    if @v.is_a?(BooleanPrimitive)
      result = !@v.value
      return BooleanPrimitive.new(result)
    else
      raise "Type error in boolean not"
    end
  end

  def to_string
    "(!#{@value.to_string})"
  end
end

class BitwiseAnd < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value & @r.value
      return IntegerPrimitive.new(result)
    else
      raise "Type error in bitwise and"
    end
  end

  def to_string
    "(#{@left.to_string} & #{@right.to_string})"
  end
end

class BitwiseOr < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value | @r.value
      return IntegerPrimitive.new(result)
    else
      raise "Type error in bitwise or"
    end
  end

  def to_string
    "(#{@left.to_string} | #{@right.to_string})"
  end
end

class BitwiseXor < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value ^ @r.value
      return IntegerPrimitive.new(result)
    else
      raise "Type error in bitwise xor"
    end
  end

  def to_string
    "(#{@left.to_string} ^ #{@right.to_string})"
  end
end

class BitwiseNot < Expression
  def initialize(value)
    @value = value
  end

  def evaluate(env)
    @v = @value.evaluate(env)
    
    if @v.is_a?(IntegerPrimitive)
      result = ~@v.value
      return IntegerPrimitive.new(result)
    else
      raise "Type error in bitwise not"
    end
  end

  def to_string
    "(~#{@value.to_string})"
  end
end

class LeftShift < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value << @r.value
      return IntegerPrimitive.new(result)
    else
      raise "Type error in bit left shift"
    end
  end

  def to_string
    "(#{@left.to_string} << #{@right.to_string})"
  end
end

class RightShift < Expression
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def evaluate(env)
    @l = @left.evaluate(env)
    @r = @right.evaluate(env)
    
    if @l.is_a?(IntegerPrimitive) && @r.is_a?(IntegerPrimitive)
      result = @l.value >> @r.value
      return IntegerPrimitive.new(result)
    else
      raise "Type error in bit right shift"
    end
  end

  def to_string
    "(#{@left.to_string} >> #{@right.to_string})"
  end
end

class CellLvalue < Expression
  attr_reader :row
  attr_reader :column

  def initialize(row, column)
    @row = row
    @column = column
  end

  def evaluate(env)
    # Only checking if expression exists, not evaluating!
    @expression = env.grid.get_cell(self)
    if @expression.nil?
      raise "Cell is nil"
    else
      return self
    end
  end

  def to_string
    "[#{@row},#{@column}]"
  end
end

class CellRvalue < Expression
  attr_reader :row
  attr_reader :column

  def initialize(row, column)
    @row = row
    @column = column
  end

  def evaluate(env)
    address = CellLvalue.new(@row, @column)
    @value = env.get(address)
    if @value.nil?
      raise "Cell is nil"
    else
      if @value.is_a?(IntegerPrimitive)
        return IntegerPrimitive.new(@value.value)
      elsif @value.is_a?(FloatPrimitive)
        return FloatPrimitive.new(@value.value)
      elsif @value.is_a?(BooleanPrimitive)
        return BooleanPrimitive.new(@value.value)
      elsif @value.is_a?(StringPrimitive)
        return StringPrimitive.new(@value.value)
      else
        raise "Value is not a primitive"
      end
    end
  end

  def to_string
    "[#{@row},#{@column}]"
  end
end

# Abstraction for casting operators
class FloatToInt < Expression
  def initialize(value)
    @value = value
  end
  
  def evaluate(env)
    @v = @value.evaluate(env)
    
    if @v.is_a?(FloatPrimitive) || @v.is_a?(IntegerPrimitive)
      @float = @v.value
      @integer = @float.to_i
      result = IntegerPrimitive.new(@integer)
      return result
    else
      raise "Type error in float to int cast"
    end
  end

  def to_string
    "(#{@value.to_string}.to_i)"
  end
end

class IntToFloat < Expression
  def initialize(value)
    @value = value
  end
  
  def evaluate(env)
    @v = @value.evaluate(env)
    
    if @v.is_a?(IntegerPrimitive) || @v.is_a?(FloatPrimitive)
      @integer = @v.value
      @float = @integer.to_f
      result = FloatPrimitive.new(@float)
      return result
    else
      raise "Type error in int to float cast"
    end
  end

  def to_string
    "(#{@value.to_string}.to_f)"
  end
end

# Abstraction for statistical functions
class Max < Expression
  def initialize(top_left, bottom_right)
    if top_left.is_a?(CellLvalue) && bottom_right.is_a?(CellLvalue)
      @top_left = top_left
      @bottom_right = bottom_right
    else
      raise "Not CellLvalues"
    end
  end

  def evaluate(env)
    # Extract the top-left and bottom-right cell addresses
    top_left_cell = @top_left
    bottom_right_cell = @bottom_right

    if ((top_left_cell.row >= env.grid.maxRows || top_left_cell.row < 0) || 
      (bottom_right_cell.row >= env.grid.maxRows || bottom_right_cell.row < 0 )) || 
      ((top_left_cell.column >= env.grid.maxColumns || top_left_cell.column < 0) || 
      (bottom_right_cell.column >= env.grid.maxColumns || bottom_right_cell.column < 0))
      raise "Provided address(') out of bounds"
    else
      start = env.grid.get_cell(CellLvalue.new(top_left_cell.row, top_left_cell.column))
      @max_value = start.value

      # Iterate through the valid cells in the specified range
      (top_left_cell.row..bottom_right_cell.row).each do |row|
        (top_left_cell.column..bottom_right_cell.column).each do |column|
          cell = CellLvalue.new(row, column)
          cell_value = env.grid.get_cell(cell)
          val = cell_value.value
          if val > @max_value
            @max_value = val
          end
        end
      end

      return IntegerPrimitive.new(@max_value) if @max_value.is_a?(Integer)
      return FloatPrimitive.new(@max_value) if @max_value.is_a?(Float)
    end
  end

  def to_string
    "[#{@top_left.to_string},#{@bottom_right.to_string}].max"
  end
end

class Min < Expression
  def initialize(top_left, bottom_right)
    if top_left.is_a?(CellLvalue) && bottom_right.is_a?(CellLvalue)
      @top_left = top_left
      @bottom_right = bottom_right
    else
      raise "Not CellLvalues"
    end
  end

  def evaluate(env)
    # Extract the top-left and bottom-right cell addresses
    top_left_cell = @top_left
    bottom_right_cell = @bottom_right

    if ((top_left_cell.row >= env.grid.maxRows || top_left_cell.row < 0) || 
      (bottom_right_cell.row >= env.grid.maxRows || bottom_right_cell.row < 0 )) || 
      ((top_left_cell.column >= env.grid.maxColumns || top_left_cell.column < 0) || 
      (bottom_right_cell.column >= env.grid.maxColumns || bottom_right_cell.column < 0))
      raise "Provided address(') out of bounds"
    else
      start = env.grid.get_cell(CellLvalue.new(top_left_cell.row, top_left_cell.column))
      @min_value = start.value

      # Iterate through the valid cells in the specified range
      (top_left_cell.row..bottom_right_cell.row).each do |row|
        (top_left_cell.column..bottom_right_cell.column).each do |column|
          cell = CellLvalue.new(row, column)
          cell_value = env.grid.get_cell(cell)
          val = cell_value.value
          if val < @min_value
            @min_value = val
          end
        end
      end

      return IntegerPrimitive.new(@min_value) if @min_value.is_a?(Integer)
      return FloatPrimitive.new(@min_value) if @min_value.is_a?(Float)
    end
  end

  def to_string
    "[#{@top_left.to_string},#{@bottom_right.to_string}].min"
  end
end

class Mean < Expression
  def initialize(top_left, bottom_right)
    if top_left.is_a?(CellLvalue) && bottom_right.is_a?(CellLvalue)
      @top_left = top_left
      @bottom_right = bottom_right
    else
      raise "Not CellLvalues"
    end
  end

  def evaluate(env)
    # Extract the top-left and bottom-right cell addresses
    top_left_cell = @top_left
    bottom_right_cell = @bottom_right

    if ((top_left_cell.row >= env.grid.maxRows || top_left_cell.row < 0) || 
      (bottom_right_cell.row >= env.grid.maxRows || bottom_right_cell.row < 0 )) || 
      ((top_left_cell.column >= env.grid.maxColumns || top_left_cell.column < 0) || 
      (bottom_right_cell.column >= env.grid.maxColumns || bottom_right_cell.column < 0))
      raise "Provided address(') out of bounds"
    else
      @mean_value = 0.0
      @num_cells = 0

      # Iterate through the valid cells in the specified range
      (top_left_cell.row..bottom_right_cell.row).each do |row|
        (top_left_cell.column..bottom_right_cell.column).each do |column|
          cell = CellLvalue.new(row, column)
          cell_value = env.grid.get_cell(cell)
          if cell_value == nil
            next
          end
          val = cell_value.value
          @mean_value = @mean_value + val
          @num_cells = @num_cells + 1
        end
      end

      @mean_value = @mean_value / @num_cells

      return IntegerPrimitive.new(@mean_value) if @mean_value.is_a?(Integer)
      return FloatPrimitive.new(@mean_value) if @mean_value.is_a?(Float)
    end
  end

  def to_string
    "[#{@top_left.to_string},#{@bottom_right.to_string}].mean"
  end
end

class Sum < Expression
  def initialize(top_left, bottom_right)
    if top_left.is_a?(CellLvalue) && bottom_right.is_a?(CellLvalue)
      @top_left = top_left
      @bottom_right = bottom_right
    else
      raise "Not CellLvalues"
    end
  end

  def evaluate(env)
    # Extract the top-left and bottom-right cell addresses
    top_left_cell = @top_left
    bottom_right_cell = @bottom_right

    if ((top_left_cell.row >= env.grid.maxRows || top_left_cell.row < 0) || 
      (bottom_right_cell.row >= env.grid.maxRows || bottom_right_cell.row < 0 )) || 
      ((top_left_cell.column >= env.grid.maxColumns || top_left_cell.column < 0) || 
      (bottom_right_cell.column >= env.grid.maxColumns || bottom_right_cell.column < 0))
      raise "Provided address(') out of bounds"
    else
      @sum_value = 0

      # Iterate through the valid cells in the specified range
      (top_left_cell.row..bottom_right_cell.row).each do |row|
        (top_left_cell.column..bottom_right_cell.column).each do |column|
          cell = CellLvalue.new(row, column)
          cell_value = env.grid.get_cell(cell)
          if cell_value == nil
            next
          end
          val = cell_value.value
          @sum_value = @sum_value + val
        end
      end

      return IntegerPrimitive.new(@sum_value) if @sum_value.is_a?(Integer)
      return FloatPrimitive.new(@sum_value) if @sum_value.is_a?(Float)
    end
  end

  def to_string
    "[#{@top_left.to_string},#{@bottom_right.to_string}].sum"
  end
end
















# ----------------TESTING APPARATUS BELOW THIS LINE!----------------










# Create a new grid
grid = Grid.new(5,5)

# # Create and set cells with values
cell_a1 = CellLvalue.new(1, 1)
cell_a2 = CellLvalue.new(1, 2)
grid.set_cell(cell_a1, IntegerPrimitive.new(5))
grid.set_cell(cell_a2, IntegerPrimitive.new(3))
cell_r1 = CellRvalue.new(1, 1)
cell_r2 = CellRvalue.new(1, 2)

# Test addition operation
expression = Add.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Addition result: #{result.to_string}"

expression = Add.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Addition result: #{result.to_string}"

expression = Add.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Addition result: #{result.to_string}"

expression = Add.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Addition result: #{result.to_string}"

expression = Add.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Addition result: #{result.to_string}"

# Test subtraction operation
expression = Subtract.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Subtraction result: #{result.to_string}"

expression = Subtract.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Subtraction result: #{result.to_string}"

expression = Subtract.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Subtraction result: #{result.to_string}"

expression = Subtract.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Subtraction result: #{result.to_string}"

expression = Subtract.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Subtraction result: #{result.to_string}"

# Test multiplication operation
expression = Multiply.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Multiplication result: #{result.to_string}"

expression = Multiply.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Multiplication result: #{result.to_string}"

expression = Multiply.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Multiplication result: #{result.to_string}"

expression = Multiply.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Multiplication result: #{result.to_string}"

expression = Multiply.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Multiplication result: #{result.to_string}"

# Test division operation
expression = Divide.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Division result: #{result.to_string}"

expression = Divide.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Division result: #{result.to_string}"

expression = Divide.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Division result: #{result.to_string}"

expression = Divide.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Division result: #{result.to_string}"

expression = Divide.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Division result: #{result.to_string}"

# Test modulo operation
expression = Modulo.new(IntegerPrimitive.new(10), IntegerPrimitive.new(3))
result = expression.evaluate(Environment.new(grid))
puts "Modulo result: #{result.to_string}"

expression = Modulo.new(FloatPrimitive.new(7.5), FloatPrimitive.new(3.0))
result = expression.evaluate(Environment.new(grid))
puts "Modulo result: #{result.to_string}"

expression = Modulo.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(2))
result = expression.evaluate(Environment.new(grid))
puts "Modulo result: #{result.to_string}"

expression = Modulo.new(IntegerPrimitive.new(5), FloatPrimitive.new(2.5))
result = expression.evaluate(Environment.new(grid))
puts "Modulo result: #{result.to_string}"

expression = Modulo.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Modulo result: #{result.to_string}"

# Test exponent operation
expression = Exponent.new(IntegerPrimitive.new(2), IntegerPrimitive.new(3))
result = expression.evaluate(Environment.new(grid))
puts "Exponent result: #{result.to_string}"

expression = Exponent.new(FloatPrimitive.new(2.5), FloatPrimitive.new(3.0))
result = expression.evaluate(Environment.new(grid))
puts "Exponent result: #{result.to_string}"

expression = Exponent.new(FloatPrimitive.new(4.0), IntegerPrimitive.new(2))
result = expression.evaluate(Environment.new(grid))
puts "Exponent result: #{result.to_string}"

expression = Exponent.new(IntegerPrimitive.new(3), FloatPrimitive.new(2.5))
result = expression.evaluate(Environment.new(grid))
puts "Exponent result: #{result.to_string}"

expression = Exponent.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Exponent result: #{result.to_string}"

# Test greater than operation
expression = GreaterThan.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Greater than result: #{result.to_string}"

expression = GreaterThan.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Greater than result: #{result.to_string}"

expression = GreaterThan.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Greater than result: #{result.to_string}"

expression = GreaterThan.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Greater than result: #{result.to_string}"

expression = GreaterThan.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Greater than result: #{result.to_string}"

string_value_1 = StringPrimitive.new("apple")
string_value_2 = StringPrimitive.new("banana")
expression = GreaterThan.new(string_value_1, string_value_2)
result = expression.evaluate(Environment.new(grid))
puts "Greater than (strings) result: #{result.to_string}"

# Test less than operation
expression = LessThan.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Less than result: #{result.to_string}"

expression = LessThan.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Less than result: #{result.to_string}"

expression = LessThan.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Less than result: #{result.to_string}"

expression = LessThan.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Less than result: #{result.to_string}"

expression = LessThan.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Less than result: #{result.to_string}"

expression = LessThan.new(string_value_1, string_value_2)
result = expression.evaluate(Environment.new(grid))
puts "Less than (strings) result: #{result.to_string}"

# Test equals operation
expression = Equals.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Equals result: #{result.to_string}"

expression = Equals.new(FloatPrimitive.new(4.5), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Equals result: #{result.to_string}"

expression = Equals.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Equals result: #{result.to_string}"

expression = Equals.new(IntegerPrimitive.new(6), FloatPrimitive.new(6.0))
result = expression.evaluate(Environment.new(grid))
puts "Equals result: #{result.to_string}"

expression = Equals.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Equals result: #{result.to_string}"

string_value_3 = StringPrimitive.new("apple")
expression = Equals.new(string_value_1, string_value_3)
result = expression.evaluate(Environment.new(grid))
puts "Equals (strings) result: #{result.to_string}"

# Test not equals operation
expression = NotEquals.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Not Equals result: #{result.to_string}"

expression = NotEquals.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Not Equals result: #{result.to_string}"

expression = NotEquals.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Not Equals result: #{result.to_string}"

expression = NotEquals.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Not Equals result: #{result.to_string}"

expression = NotEquals.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Not Equals result: #{result.to_string}"

expression = NotEquals.new(string_value_1, string_value_2)
result = expression.evaluate(Environment.new(grid))
puts "Not Equals (strings) result: #{result.to_string}"

# Test less than or equal to operation
expression = LessThanOrEqual.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Less than or equal to result: #{result.to_string}"

expression = LessThanOrEqual.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Less than or equal to result: #{result.to_string}"

expression = LessThanOrEqual.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Less than or equal to result: #{result.to_string}"

expression = LessThanOrEqual.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Less than or equal to result: #{result.to_string}"

expression = LessThanOrEqual.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Less than or equal to result: #{result.to_string}"

expression = LessThanOrEqual.new(string_value_1, string_value_3)
result = expression.evaluate(Environment.new(grid))
puts "Less than or equal to (strings) result: #{result.to_string}"

# Test greater than or equal to operation
expression = GreaterThanOrEqual.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Greater than or equal to result: #{result.to_string}"

expression = GreaterThanOrEqual.new(FloatPrimitive.new(4.5), FloatPrimitive.new(6.25))
result = expression.evaluate(Environment.new(grid))
puts "Greater than or equal to result: #{result.to_string}"

expression = GreaterThanOrEqual.new(FloatPrimitive.new(4.5), IntegerPrimitive.new(6))
result = expression.evaluate(Environment.new(grid))
puts "Greater than or equal to result: #{result.to_string}"

expression = GreaterThanOrEqual.new(IntegerPrimitive.new(6), FloatPrimitive.new(4.5))
result = expression.evaluate(Environment.new(grid))
puts "Greater than or equal to result: #{result.to_string}"

expression = GreaterThanOrEqual.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Greater than or equal to result: #{result.to_string}"

expression = GreaterThanOrEqual.new(string_value_1, string_value_3)
result = expression.evaluate(Environment.new(grid))
puts "Greater than or equal to (strings) result: #{result.to_string}"

# Test Bitwise And operation
expression = BitwiseAnd.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise AND result: #{result.to_string}"

expression = BitwiseAnd.new(IntegerPrimitive.new(9), IntegerPrimitive.new(12))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise AND result: #{result.to_string}"

expression = BitwiseAnd.new(IntegerPrimitive.new(6), IntegerPrimitive.new(2))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise AND result: #{result.to_string}"

expression = BitwiseAnd.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Bitwise AND result: #{result.to_string}"

# Test Bitwise Or operation
expression = BitwiseOr.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise OR result: #{result.to_string}"

expression = BitwiseOr.new(IntegerPrimitive.new(9), IntegerPrimitive.new(12))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise OR result: #{result.to_string}"

expression = BitwiseOr.new(IntegerPrimitive.new(6), IntegerPrimitive.new(2))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise OR result: #{result.to_string}"

expression = BitwiseOr.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Bitwise OR result: #{result.to_string}"

# Test Bitwise Xor operation
expression = BitwiseXor.new(IntegerPrimitive.new(5), IntegerPrimitive.new(3))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise XOR result: #{result.to_string}"

expression = BitwiseXor.new(IntegerPrimitive.new(9), IntegerPrimitive.new(12))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise XOR result: #{result.to_string}"

expression = BitwiseXor.new(IntegerPrimitive.new(6), IntegerPrimitive.new(2))
result = expression.evaluate(Environment.new(grid))
puts "Bitwise XOR result: #{result.to_string}"

expression = BitwiseXor.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Bitwise XOR result: #{result.to_string}"

# Test bitwise NOT operation with a single parameter
expression = BitwiseNot.new(cell_r1)
result = expression.evaluate(Environment.new(grid))
puts "Bitwise NOT result: #{result.to_string}"

# Test Left Shift operation
expression = LeftShift.new(IntegerPrimitive.new(5), IntegerPrimitive.new(2))
result = expression.evaluate(Environment.new(grid))
puts "Left Shift result: #{result.to_string}"

expression = LeftShift.new(IntegerPrimitive.new(9), IntegerPrimitive.new(1))
result = expression.evaluate(Environment.new(grid))
puts "Left Shift result: #{result.to_string}"

expression = LeftShift.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Left Shift result: #{result.to_string}"

# Test Right Shift operation
expression = RightShift.new(IntegerPrimitive.new(8), IntegerPrimitive.new(2))
result = expression.evaluate(Environment.new(grid))
puts "Right Shift result: #{result.to_string}"

expression = RightShift.new(IntegerPrimitive.new(16), IntegerPrimitive.new(3))
result = expression.evaluate(Environment.new(grid))
puts "Right Shift result: #{result.to_string}"

expression = RightShift.new(cell_r1, cell_r2)
result = expression.evaluate(Environment.new(grid))
puts "Right Shift result: #{result.to_string}"

# Test casting (float to int)
float_value = FloatPrimitive.new(7.5)
expression = FloatToInt.new(float_value)
result = expression.evaluate(Environment.new(grid))
puts "Float to Int cast result: #{result.to_string}"

# Test casting (int to float)
int_value = IntegerPrimitive.new(5)
expression = IntToFloat.new(int_value)
result = expression.evaluate(Environment.new(grid))
puts "Int to Float cast result: #{result.to_string}"

testBool1 = BooleanPrimitive.new(true)
testBool2 = BooleanPrimitive.new(false)

# Test logical AND operation
expression = And.new(testBool1, testBool2)
result = expression.evaluate(Environment.new(grid))
puts "Logical AND result: #{result.to_string}"

expression = And.new(testBool1, testBool1)
result = expression.evaluate(Environment.new(grid))
puts "Logical AND result: #{result.to_string}"

# Test logical OR operation
expression = Or.new(testBool1, testBool2)
result = expression.evaluate(Environment.new(grid))
puts "Logical OR result: #{result.to_string}"

expression = Or.new(testBool2, testBool2)
result = expression.evaluate(Environment.new(grid))
puts "Logical OR result: #{result.to_string}"

# Test logical NOT operation
expression = Not.new(testBool2)
result = expression.evaluate(Environment.new(grid))
puts "Logical NOT result: #{result.to_string}"

expression = Not.new(testBool1)
result = expression.evaluate(Environment.new(grid))
puts "Logical NOT result: #{result.to_string}"

# Set values in the grid
for i in 0..4 do
  for j in 0..4 do
    k = i + j
    cell = CellLvalue.new(i, j)
    grid.set_cell(cell, IntegerPrimitive.new(k))
  end
end

cell_top1 = CellLvalue.new(0, 0)
cell_bottom1 = CellLvalue.new(4, 4)
cell_top2 = CellLvalue.new(2, 2)
cell_bottom2 = CellLvalue.new(4, 2)

# Test Max operation
expression = Max.new(cell_top1, cell_bottom1)
result = expression.evaluate(Environment.new(grid))
puts "Max result: #{result.to_string}"

expression = Max.new(cell_top2, cell_bottom2)
result = expression.evaluate(Environment.new(grid))
puts "Max result: #{result.to_string}"

# Test Min operation
expression = Min.new(cell_top1, cell_bottom1)
result = expression.evaluate(Environment.new(grid))
puts "Min result: #{result.to_string}"

expression = Min.new(cell_top2, cell_bottom2)
result = expression.evaluate(Environment.new(grid))
puts "Min result: #{result.to_string}"

# Test Mean operation
expression = Mean.new(cell_top1, cell_bottom1)
result = expression.evaluate(Environment.new(grid))
puts "Mean result: #{result.to_string}"

expression = Mean.new(cell_top2, cell_bottom2)
result = expression.evaluate(Environment.new(grid))
puts "Mean result: #{result.to_string}"

# Test Sum operation
expression = Sum.new(cell_top1, cell_bottom1)
result = expression.evaluate(Environment.new(grid))
puts "Sum result: #{result.to_string}"

expression = Sum.new(cell_top2, cell_bottom2)
result = expression.evaluate(Environment.new(grid))
puts "Sum result: #{result.to_string}"



# Test to_string method for CellLvalue
cell_a1 = CellLvalue.new(1, 1)
puts "CellLvalue to_string: #{cell_a1.to_string}"

# Test to_string method for CellRvalue
cell_r1 = CellRvalue.new(1, 1)
puts "CellRvalue to_string: #{cell_r1.to_string}"

# Test to_string method for Add
expression = Add.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "Add to_string: #{expression.to_string}"

# Test to_string method for Subtract
expression = Subtract.new(IntegerPrimitive.new(6), IntegerPrimitive.new(4))
puts "Subtract to_string: #{expression.to_string}"

# Test to_string method for Multiply
expression = Multiply.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "Multiply to_string: #{expression.to_string}"

# Test to_string method for Divide
expression = Divide.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "Divide to_string: #{expression.to_string}"

# Test to_string method for Modulo
expression = Modulo.new(IntegerPrimitive.new(7), IntegerPrimitive.new(3))
puts "Modulo to_string: #{expression.to_string}"

# Test to_string method for Exponent
expression = Exponent.new(IntegerPrimitive.new(2), IntegerPrimitive.new(3))
puts "Exponent to_string: #{expression.to_string}"

# Test to_string method for GreaterThan
expression = GreaterThan.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "GreaterThan to_string: #{expression.to_string}"

# Test to_string method for LessThan
expression = LessThan.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "LessThan to_string: #{expression.to_string}"

# Test to_string method for Equals
expression = Equals.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "Equals to_string: #{expression.to_string}"

# Test to_string method for NotEquals
expression = NotEquals.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "NotEquals to_string: #{expression.to_string}"

# Test to_string method for LessThanOrEqual
expression = LessThanOrEqual.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "LessThanOrEqual to_string: #{expression.to_string}"

# Test to_string method for GreaterThanOrEqual
expression = GreaterThanOrEqual.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "GreaterThanOrEqual to_string: #{expression.to_string}"

# Test to_string method for BitwiseAnd
expression = BitwiseAnd.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "BitwiseAnd to_string: #{expression.to_string}"

# Test to_string method for BitwiseOr
expression = BitwiseOr.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "BitwiseOr to_string: #{expression.to_string}"

# Test to_string method for BitwiseXor
expression = BitwiseXor.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "BitwiseXor to_string: #{expression.to_string}"

# Test to_string method for LeftShift
expression = LeftShift.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "LeftShift to_string: #{expression.to_string}"

# Test to_string method for RightShift
expression = RightShift.new(IntegerPrimitive.new(4), IntegerPrimitive.new(6))
puts "RightShift to_string: #{expression.to_string}"

# Test to_string method for And
expression = And.new(IntegerPrimitive.new(1), IntegerPrimitive.new(0))
puts "And to_string: #{expression.to_string}"

# Test to_string method for Or
expression = Or.new(IntegerPrimitive.new(1), IntegerPrimitive.new(0))
puts "Or to_string: #{expression.to_string}"

# Test to_string method for Not
expression = Not.new(IntegerPrimitive.new(0))
puts "Not to_string: #{expression.to_string}"

# Test to_string method for FloatToInt
expression = FloatToInt.new(FloatPrimitive.new(3.14))
puts "FloatToInt to_string: #{expression.to_string}"

# Test to_string method for IntToFloat
expression = IntToFloat.new(IntegerPrimitive.new(42))
puts "IntToFloat to_string: #{expression.to_string}"

# Test to_string method for BitwiseNot
expression = BitwiseNot.new(IntegerPrimitive.new(42))
puts "BitwiseNot to_string: #{expression.to_string}"

# Test to_string method for Max
expression = Max.new(cell_top1, cell_bottom1)
puts "Max to_string: #{expression.to_string}"

# Test to_string method for Min
expression = Min.new(cell_top1, cell_bottom1)
puts "Min to_string: #{expression.to_string}"

# Test to_string method for Mean
expression = Mean.new(cell_top1, cell_bottom1)
puts "Mean to_string: #{expression.to_string}"

# Test to_string method for Sum
expression = Sum.new(cell_top1, cell_bottom1)
puts "Sum to_string: #{expression.to_string}"