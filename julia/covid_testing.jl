### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ b8789786-3511-11eb-1377-51b8fbff55b7
begin
	using Images
	using FileIO
end

# ╔═╡ 9c30c646-352e-11eb-2062-a793ccb04fa0
begin
	using DataStructures
	using Random

	function simulate_testing(population::Int64; 
			                  prevalence::Float64, 
							  FPR::Float64, FNR::Float64)
		counts = DefaultDict(0)
		for i=1:population
			cov_pos = i % floor(1/prevalence) == 0.0

			if cov_pos
				rand() < FNR ? test_pos = false : test_pos = true
			else
				rand() < FPR ? test_pos = true : test_pos = false
			end

			outcome = (cov_pos, test_pos)
			counts[outcome] += 1
		end
		counts
	end

	function simulate_covid_prob(population::Int64; 
			                     prevalence::Float64, 
							     FPR::Float64, FNR::Float64)
		counts = simulate_testing(population, 
								  prevalence=prevalence, 
						 		  FPR=FPR, FNR=FNR)
		100 * counts[(true, true)]/(counts[(true, true)] + counts[(false, true)])
	end
	
end

# ╔═╡ 01447f9a-3533-11eb-08ae-5380d56e6e27
md" Given prevalence (i.e. what fraction of the population is infected) of covid in a population and the false positive and false negative rate for the PCR test, if the test came positive what would be the probability of being infected? 

How does this probability change if one is feeling the symptoms of covid?

These questions can be answered by using probability or doing a simulation, but in both the cases the most important part is the assessment of the prior. 

In case of no symptoms one can use the prevalence as the prior, but when there are symptoms the prior should be higher than the general prevalence."

# ╔═╡ 3fd25a70-3531-11eb-2efc-2b48eae57cb5
begin
	FPR = 0.01
	FNR = 0.1
	prevalence = 1/1000
end

# ╔═╡ e2983572-352e-11eb-3c3e-8fe7faaacc28
begin
	population = 10_000_000
	simulate_covid_prob(population; prevalence=prevalence, FPR=FPR, FNR=FNR)
end

# ╔═╡ 723f6c92-3511-11eb-329c-e9c2a355f0e9
md" $+C$ : Infected with covid\
$-C$ : Not infected\
$+T$ : Tested Positive\
$-T$ : Tested Negative

Say the prevalence of the disease in the population is 1 in 1000. $P(+C) = 0.001$

and the test has 1% false positives rate, 

$P(+T|-C) = 0.01, ~~\therefore P(-T|-C) = 0.99$

and 10% false negative rate.

$P(-T|+C) = 0.1, ~~\therefore P(+T|+C) = 0.9$

## 

From Bayes Rule we know that:

$P(A|B) = \frac{P(B|A) \cdot P(A)}{P(B)}$

$P(B) = P(B|A) \cdot P(A) + P(B|\neg A) \cdot P(\neg A)$



If I get tested positive then probability that I have covid is:

$P(+C|+T) = \frac{P(+T|+C) \cdot P(+C)}{P(+T)}$

$P(+T) = P(+T|+C)P(+C) + P(+T|-C)P(-C)$
$~~~~= 0.9*0.001 + 0.01*0.999 = 0.01089$


$P(+C|+T) = 0.8* 0.001 / 0.01089 = 0.0826$

The probability of having the disease is 8.2%
"

# ╔═╡ bd404cc8-352f-11eb-24dc-576026e2cda8
function compute_covid_prob(;prevalence, FPR, FNR, test=true)
	if test == true # test came positive
		prob_pos_test = FPR*(1-prevalence) + (1-FNR)*prevalence
		prob = 100 * (1 - FNR) * prevalence / prob_pos_test
	else # test came negative
		prob_pos_test = (1-FPR)*(1-prevalence) + FNR*prevalence
		prob = 100 * (1-FPR)*prevalence/prob_pos_test
	end
	prob
end

# ╔═╡ 5d6de6e6-3531-11eb-12b4-d5ef9b250ad6
compute_covid_prob(prevalence=prevalence, FPR=FPR, FNR=FNR, test=true)

# ╔═╡ 5cb7871a-3591-11eb-10a7-e95562f28d9b
compute_covid_prob(prevalence=prevalence, FPR=FPR, FNR=FNR, test=false)

# ╔═╡ c13c8ce8-353d-11eb-362e-239be46b5263
begin
	using Plots	
	p = plot(xlabel="prevalence", ylabel="% prob of infection",
			 yticks = 0:3:60, title="what if I tested positive?")
	for prev=0.001:0.001:0.01
		prob = compute_covid_prob(prevalence=prev, FPR=FPR, FNR=FNR, test=true)
		scatter!(p, [prev], [prob], marker=:x, color="salmon", label="")
	end
	p
end

# ╔═╡ 7e02d618-3591-11eb-102d-c9611669e80b
begin
	p2 = plot(xlabel="prevalence", ylabel="% prob of infection",
			  title="what if I tested negative?")
	for prev=0.001:0.001:0.01
		prob = compute_covid_prob(prevalence=prev, FPR=FPR, FNR=FNR, test=false)
		scatter!(p2, [prev], [prob], marker=:x, color="salmon", label="")
	end
	p2
end

# ╔═╡ addbe57a-3524-11eb-1cda-6b8ab833cf2e
tree = load("/Users/swairshah/Desktop/testing.png")

# ╔═╡ c258c948-352e-11eb-2bd4-6fdd82c0cdb8
md" We can write a simulation of this tree as follows"

# ╔═╡ Cell order:
# ╟─01447f9a-3533-11eb-08ae-5380d56e6e27
# ╠═3fd25a70-3531-11eb-2efc-2b48eae57cb5
# ╠═5d6de6e6-3531-11eb-12b4-d5ef9b250ad6
# ╠═5cb7871a-3591-11eb-10a7-e95562f28d9b
# ╠═e2983572-352e-11eb-3c3e-8fe7faaacc28
# ╠═c13c8ce8-353d-11eb-362e-239be46b5263
# ╠═7e02d618-3591-11eb-102d-c9611669e80b
# ╟─723f6c92-3511-11eb-329c-e9c2a355f0e9
# ╠═bd404cc8-352f-11eb-24dc-576026e2cda8
# ╟─b8789786-3511-11eb-1377-51b8fbff55b7
# ╟─addbe57a-3524-11eb-1cda-6b8ab833cf2e
# ╟─c258c948-352e-11eb-2bd4-6fdd82c0cdb8
# ╠═9c30c646-352e-11eb-2062-a793ccb04fa0
