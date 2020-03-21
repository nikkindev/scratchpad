# Find repeating number in an array on constant space and linear time using 
# Floyd's hare and tortoise algorithm
# Used mainly for cycle detection algorithm
# When a duplicate is present in an array of numbers 1 to n, when the value of the list is 
# taken an index of the next value, this forms a cycle and Floyd's algorithm can be used to 
# detect this cycle

# Code: https://www.youtube.com/watch?v=pKO9UjSeLew (Joma)
a = [3,1,3,4,2]

def find_duplicate(n):
  # Start from the head of the linked list of the start of an array
  tortoise = n[0]
  hare = n[0]
  while True:
    # tortoise traverses one step, hare two steps
    tortoise = n[tortoise]
    hare = n[n[hare]]
    if (tortoise == hare):  break
  # when hare == tortoise, the hare starts from the beginning movign only one step now
  ptr1 = n[0]
  ptr2 = tortoise
  while ptr1 != ptr2:
    # When tortoise == hare again, the value is the repeated value
    ptr1 = n[ptr1]
    ptr2 = n[ptr2]
  return(ptr1)

print(find_duplicate(a))