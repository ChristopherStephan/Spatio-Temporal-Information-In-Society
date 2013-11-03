-- Write a Lua function that calculates the 50 first prime numbers

function isPrime(x)
        if x < 2 then
                return false
        end

        if x == 2 then
                return 2
        end
        
        if x % 2 == 0 then
                return false
        end

        for i = 3, math.sqrt(x), 2 do
                if x % i == 0 then
                        return false
                end
        end
        
        return true
end

local function primesUntil(number)
        i = 1
        while i < number do
                if (isPrime(i)) then
                        print(i)
                end
                i = i + 1
        end
end

 
--primesUntil(50)

-- Write a Lua function that calculates the 15 first Mersenne primes.
-- A Mersenne prime is a number p such that 2^p - 1 is prime.

local function mersenne15()
        totalMersennePrimes = 1
        while totalMersennePrimes <= 15 do
                for p = 1, math.huge do
                        if isPrime(math.pow(2, p) - 1) then
                                print(math.pow(2, p) - 1)
                                totalMersennePrimes = totalMersennePrimes + 1
                        end
                end
        end
end

mersenne15()
