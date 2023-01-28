#include<iostream>
#include<vector>
#include<algorithm>

using namespace std;

int getMaxSum(vector<int>& nums, int b, int e) {
    if (b == e) return nums[b];
    if (b == e - 1) return max(nums[b], max(nums[e], nums[b]+nums[e]));
    int m = (b + e) / 2;
    int maxleft = nums[m];
    int maxright = nums[m];
    int sum = nums[m];

    for (int i = m + 1; i <= e; i++) {
        sum += nums[i];
        maxright = max(maxright, sum);
    }

    sum = nums[m];
    for (int i = m - 1; i >= b; i--) {
        sum += nums[i];
        maxleft = max(maxleft, sum);
    }
    cout << "maxleft "<< maxleft << " maxright "<< maxright 
        << " num " << nums[m] << endl;
    return max(getMaxSum(nums, b, m - 1), max(getMaxSum(nums, m + 1, e), maxleft+maxright-nums[m]));
}

int maxSubArray(vector<int>& nums) {
    return getMaxSum(nums, 0, nums.size()-1);
}

int main()
{
    int arr[9] = {-2,4,5,-1,3,-2,8,4,-1};
    vector<int> vec(arr, arr+9);

    cout << "max is " << maxSubArray(vec) << endl;

}
