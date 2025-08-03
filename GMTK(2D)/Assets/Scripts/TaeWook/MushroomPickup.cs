using UnityEngine;

public class MushroomPickup : MonoBehaviour
{
    public string playerTag = "Player";
    public string cloneTag = "Ghost";

    public GameObject collectEffectPrefab; // ������ ���� ����Ʈ ������
    public float effectDuration = 1.0f; // ����Ʈ ���ӽð�

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag(playerTag))
        {
            var characterStatus = other.GetComponent<CharacterStatus>();
            if (characterStatus != null)
            {
                if (characterStatus.currentStatus == CharacterStatus.Status.Chick)
                {
                    characterStatus.ChangeStatus(CharacterStatus.Status.Chicken);

                    // �� ���� ����
                }
                else if (characterStatus.currentStatus == CharacterStatus.Status.Chicken)
                {
                    SoundManager.Instance.PlayOneShotSound("SFX_Eat_Muschroom");
                    // �� ���� ���� (�� ������Ʈ ���� ��)
                }
            }
            // �ް� ���´� ���⼭ ���� �ٷ� �ʿ� ����
            // ����Ʈ ��� �� ���� ���� ó��
            if (collectEffectPrefab != null)
            {
                GameObject effect = Instantiate(collectEffectPrefab, transform.position, Quaternion.identity);
                Destroy(effect, effectDuration);
            }
            gameObject.SetActive(false);  // ������ ������ �����
        }
    }
}