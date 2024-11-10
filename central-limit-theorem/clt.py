import random
from tqdm import tqdm
from scipy import stats
import numpy as np

class Events:
    def __init__(
        self,
        weights: list[int],
        forward_step: int = 1,
        backward_step: int = 1
    ) -> None:
        self.weights = weights
        self.choices = [0,1]
        self.forward_step = forward_step
        self.backward_step = backward_step
        self.final_positions = []

    def simulate(self, rounds: int, steps: int) -> None:
        for i in tqdm(range(rounds)):
            position = 0 # Starting position
            for _ in range(steps):
                result = random.choices(
                    population = self.choices,
                    weights = self.weights,
                    k = 1
                )[0]
                if result == 0:
                    position += self.forward_step
                elif result == 1:
                    position -= self.backward_step
            self.final_positions.append(position)

    @property
    def result(self):
        return self.final_positions

    @property
    def gaussian_fit(self):
        mu, sigma = stats.norm.fit(self.final_positions)
        x = np.linspace(min(self.final_positions), max(self.final_positions), 1000)
        y = stats.norm.pdf(x, mu, sigma)
        return x, y, mu, sigma
